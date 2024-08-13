
public struct RolandEditorTrussWerk {

  public typealias MapItem = RolandMultiSysexTrussWerk.MapItem
  
  public let displayId: String
  public let map: [MapItem]
  public let deviceId: EditorValueTransform
  /// The header bytes used in a fetch request, not including 0xf0, 0x41
  public let sysexWerk: RolandSysexTrussWerk
  
  public let dict: [SynthPath:(address: RolandAddress, werk: AnyRolandSysexTrussWerk)]
  
  public init(_ displayId: String, _ map: [MapItem], deviceId: EditorValueTransform, sysexWerk: RolandSysexTrussWerk) {
    self.displayId = displayId
    self.map = map
    self.deviceId = deviceId
    self.sysexWerk = sysexWerk
    
    self.dict = map.dict(transform: { [$0.path : ($0.address, $0.werk)] })
  }

  public func sysexMap() -> [(SynthPath, any SysexTruss)] {
    map.map { ($0.path, $0.werk.anyTruss) }
  }
  
  public func backupTruss(_ werk: RolandSysexTrussWerk, start: RolandAddress, paths: [SynthPath], otherValidSizes: [Int]? = nil) -> BackupTruss {
    RolandMultiSysexTrussWerk.createBackupTruss(werk, displayId, map.filter({ paths.contains($0.path) }), start: start, otherValidSizes: otherValidSizes)
  }
}

public extension RolandEditorTrussWerk {

  /// default is a single request across the entire size of the patch (even if it's multi)
  func defaultFetchTransforms() -> [SynthPath:FetchTransform] {
    map.dict {
      [$0.path : fetchTransform(forAddress: $0.address, size: $0.werk.size, addressCount: $0.werk.werk.addressCount)]
    }
  }
  
  func fetchBytes(forAddress address: RolandAddress, size: RolandAddress, addressCount: Int) -> (_ editor: AnySynthEditor) -> [UInt8] {
    let addressBytes = address.sysexBytes(count: addressCount)
    let sizeBytes = size.sysexBytes(count: addressCount)
    let data = addressBytes + sizeBytes + [RolandChecksum(address: address, dataBytes: sizeBytes, addressCount: addressCount), 0xf7]
    return {
      [0xf0, 0x41, UInt8(try! $0.intValue(deviceId))] + sysexWerk.modelId + [0x11] + data
    }
  }
  
  func fetchTransform(forAddress address: RolandAddress, size: RolandAddress, addressCount: Int) -> FetchTransform {
    .truss(fetchBytes(forAddress: address, size: size, addressCount: addressCount))
  }

  func singleFetchTransform(forPath path: SynthPath) -> FetchTransform? {
    guard let (address, werk) = dict[path] else { return nil }
    return fetchTransform(forAddress: address, size: werk.size, addressCount: werk.werk.addressCount)
  }

  /// a FetchTransform that fetches a multipatch via multiple fetch requests; one for each subpatch. or a multi bank, by fetching every patch via the same multiple fetch requests (the most granular way to fetch; needed e.g. by JD-Xi for drums.
  func multiFetchTransform(path: SynthPath) -> FetchTransform? {
    guard let (address, werk) = dict[path] else { return nil }
    
    switch werk {
    case let multiWerk as RolandMultiPatchTrussWerk:
      return multiFetchTransform(multiWerk: multiWerk, start: address)
      
    case let multiBankWerk as RolandMultiBankTrussWerk:
      return .sequence(multiBankWerk.truss.patchCount.map {
        let offsetAddress = multiBankWerk.iso.address(UInt8($0))
        return multiFetchTransform(multiWerk: multiBankWerk.patchWerk, start: address + offsetAddress)
      })

      default:
        return nil
    }
    
  }
  
  func multiFetchTransform(multiWerk: RolandMultiPatchTrussWerk, start: RolandAddress) -> FetchTransform {
    let sortedMap = multiWerk.map.sorted(by: { $0.address < $1.address })
    return .custom() { editor in
      sortedMap.map {
        let address = $0.address + start
        let bytes = fetchBytes(forAddress: address, size: $0.werk.size, addressCount: $0.werk.werk.addressCount)(editor)
        return $0.werk.truss.fetchRequest(bytes)
      }
    }
  }

    

  func midiOuts() -> [(path: SynthPath, transform: MidiTransform)] {
    map.compactMap { (path, address, werk) in
      switch werk {
      case let b as RolandSinglePatchTrussWerk:
        return (path, singleBundle(werk: b, address: address))
        
      case let b as RolandMultiPatchTrussWerk:
        return (path, multiBundle(werk: b, address: address))
        
      case let b as RolandSingleBankTrussWerk:
        return (path, .single(throttle: 0, .bank({ editor, bodyData, location in
          let offset = b.iso.address(UInt8(location))
          let deviceId = try! UInt8(editor.intValue(deviceId))
          return Self.mm(b.patchWerk.sysexDataFn(bodyData, deviceId, address + offset))
        })))
        
      case let b as RolandMultiBankTrussWerk:
        return (path, .multi(throttle: 0, .bank({ editor, bodyData, location in
          let offset = b.iso.address(UInt8(location))
          let deviceId = try! UInt8(editor.intValue(deviceId))
          return Self.mm(b.patchWerk.sysexDataFn(bodyData, deviceId, address + offset))
        })))
        
      default:
        return nil
      }
    }
  }

  func singleBundle(werk: RolandSinglePatchTrussWerk, address: RolandAddress) -> MidiTransform {
    
    let params = werk.truss.params
    let paramT: MidiTransform.Fn<SinglePatchTruss>.Param = { editor, bodyData, parm, value in
      let deviceId = try! UInt8(editor.intValue(deviceId))
      let data = werk.werk.paramSetData(bodyData, deviceId: deviceId, address: address, path: parm.path, params: params)
      return Self.mm([data])
    }

    let patchT: MidiTransform.Fn<SinglePatchTruss>.Whole = { editor, bodyData in
      let deviceId = try! UInt8(editor.intValue(deviceId))
      let data = werk.sysexDataFn(bodyData, deviceId, address)
      return Self.mm(data)
    }
    
    let nameT: MidiTransform.Fn<SinglePatchTruss>.Name = { editor, bodyData, path, name in
      // TODO
      return nil
    }
    
    return .single(throttle: 10, .patch(param: paramT, patch: patchT, name: nameT))
  }
  

  // a default func to break byte arrays into timed msgs
  static func mm(_ bytes: [[UInt8]]) -> [(MidiMessage, Int)] {
    bytes.map { (.sysex($0), 30 )}
  }
  
  
  func multiBundle(werk: RolandMultiPatchTrussWerk, address: RolandAddress) -> MidiTransform {
    
    let paramsT: MidiTransform.Fn<MultiPatchTruss>.Params = { editor, bodyData, values in

      let deviceId = try! UInt8(editor.intValue(deviceId))
      var subchanges = [SynthPath:NuPatchChange]()
      // go through all the changes
      values.forEach {
        // for each change, find what subpatch it belongs to
        for item in werk.map {
          let prefix = item.path
          guard $0.key.starts(with: prefix) else { continue }
          let newChange: NuPatchChange = .paramsChange([$0.key.subpath(from: prefix.count) : $0.value])
          // collect them all
          subchanges[prefix] = (subchanges[prefix] ?? .paramsChange([:])).updated(withChange: newChange)
        }
      }
      
      // if there are changes across multiple subpatches, send the whole patch!
      if subchanges.count > 1 {
        return Self.mm(werk.sysexDataFn(bodyData, deviceId, address))
      }
      
      guard let changePair = subchanges.first,
            let subdata = bodyData[changePair.key],
            let subpatchItem = werk.dict[changePair.key],
        case let .paramsChange(subparams) = changePair.value else { return nil }
      
      let fullSubpatchAddress = address + subpatchItem.address
      if subparams.count > 1 {
        //, if there are multiple changes, send subpatch
        let data = subpatchItem.werk.sysexDataFn(subdata, deviceId, fullSubpatchAddress)
        return Self.mm(data)
      }
      else if let pair = subparams.first {
        //  otherwise, send individual change
        return Self.mm([subpatchItem.werk.werk.paramSetData(subdata, deviceId: deviceId, address: fullSubpatchAddress, path: pair.key, params: subpatchItem.werk.truss.params)])
      }
      else {
        return nil
      }
    }

    let patchT: MidiTransform.Fn<MultiPatchTruss>.Whole = { editor, bodyData in
      let deviceId = try! UInt8(editor.intValue(deviceId))
      let data = werk.sysexDataFn(bodyData, deviceId, address)
      return Self.mm(data)
    }
    
    let nameT: MidiTransform.Fn<MultiPatchTruss>.Name = { editor, bodyData, path, name in
      let deviceId = try! UInt8(editor.intValue(deviceId))
      // for now, assume that top-level name is always stored at .common path
      let p = path.count == 0 ? werk.truss.namePath ?? [.common] : path
      guard let item = werk.dict[p],
            let namePack = item.werk.truss.namePackIso,
            let subdata = bodyData[p] else { return nil }
      let fullSubpatchAddress = address + item.address
      return Self.mm([item.werk.werk.nameSetData(subdata, deviceId: deviceId, address: fullSubpatchAddress, namePackIso: namePack)])
    }
    
    return .multi(throttle: 10, .multiPatch(params: paramsT, patch: patchT, name: nameT))
  }

}
