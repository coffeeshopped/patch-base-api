
public struct RolandMultiSysexTrussWerk {

  public typealias MapItem = (path: SynthPath, address: RolandAddress, werk: AnyRolandSysexTrussWerk)

}

public extension RolandMultiSysexTrussWerk {
  
  static func defaultParseBodyData(_ fileData: [UInt8], sysexWerk: RolandSysexTrussWerk, map: [MapItem]) throws -> MultiSysexTrussBodyData {
    let sysex = SysexData(data: Data(fileData))

    // determine the base address of the fetched data
    let baseAdd = sysex.map { sysexWerk.address(forSysex: $0.bytes()) }.sorted(by: { $0 < $1 }).first
    guard let baseAddress = baseAdd else {
      // if no base address found, init subpatches
      var d = BackupTruss.BodyData()
      try map.forEach {
        d[$0.path] = try $0.werk.anyTruss.createInitAnyBodyData()
      }
      return d
    }

    var subpatchData = [Int:[[UInt8]]]()
    sysex.forEach { msg in
      let bytes = msg.bytes()
      let offsetAddress = sysexWerk.address(forSysex: bytes) - baseAddress
      // find key that matches the offset address
      guard let index = mapIndex(address: offsetAddress, sysex: msg.bytes(), map: map) else { return }
      subpatchData[index] = (subpatchData[index] ?? []) + [bytes]
    }

    var p = MultiSysexTrussBodyData()
    try subpatchData.forEach { (index, data) in
      let item = map[index]
      let fileData = data.reduce([], +)
      p[item.path] = try item.werk.anyTruss.parseAnyBodyData(fileData: fileData)
    }

    // UPDATE: No, don't. FullPerfs need blank subpatches for preset parts
    // for any unfilled subpatches, init them
//    rolandMap.forEach {
//      guard p[$0.path] == nil else { return }
//      p[$0.path] = $0.sysex.templatedSysexType.init()
//    }

    return p
  }

  static func mapIndex(address: RolandAddress, sysex: [UInt8], map: [MapItem]) -> Int? {
      for (i, item) in map.enumerated() {
        switch item.werk {
        case let b as RolandSinglePatchTrussWerk:
          if address == item.address && b.truss.isValidFileData(sysex) {
            return i
          }
        case let b as RolandMultiPatchTrussWerk:
          if b.mapIndex(address: address - item.address, sysex: sysex) != nil {
            return i
          }
        // TODO: Add RolandSingleBankTrussWerk
        case let b as RolandMultiBankTrussWerk:
          if b.containsOffset(address: address - item.address) {
            return i
          }
        default:
          break
        }
      }
      return nil
    }

  static func path(forData data: [UInt8], start: RolandAddress, sysexWerk: RolandSysexTrussWerk, map: [MapItem]) -> SynthPath? {
    let offsetAddress = sysexWerk.address(forSysex: data) - start
    // find key that matches the offset address
    guard let index = mapIndex(address: offsetAddress, sysex: data, map: map) else { return nil }
    return map[index].path
  }
  
  static func defaultSysexData(_ bodyData: [SynthPath:Any], deviceId: UInt8, address: RolandAddress, map: [MapItem]) throws -> [[UInt8]] {
    try map.compactMap {
      guard let bd = bodyData[$0.path] as? SysexBodyData else { return nil }
      return try $0.werk.anySysexData(bd, deviceId: deviceId, address: $0.address + address)
    }.reduce([], +)
  }
  
  static func createFullRefTruss(_ sysexWerk: RolandSysexTrussWerk, _ displayId: String, _ map: [MapItem], start: RolandAddress, isos: FullRefTruss.Isos, refPath: SynthPath = [.perf], initFile: String = "", sections: [(String, [SynthPath])]) -> FullRefTruss {
    
    let trussMap = map.map { ($0.path, $0.werk.anyTruss) }
    
    return FullRefTruss(displayId, trussMap: trussMap, refPath: refPath, isos: isos, sections: sections, initFile: initFile, createFileData: .fn({ b, e in
      try defaultSysexData(b, deviceId: UInt8(RolandDefaultDeviceId), address: start, map: map).reduce([], +)
    }), pathForData: {
      RolandMultiSysexTrussWerk.path(forData: $0, start: start, sysexWerk: sysexWerk, map: map)
    })
  }

  static func createBackupTruss(_ sysexWerk: RolandSysexTrussWerk, _ synthName: String, _ map: [MapItem], start: RolandAddress, initFile: String? = nil, otherValidSizes: [Int]? = nil) -> BackupTruss {
    
    let trussMap = map.map { ($0.path, $0.werk.anyTruss) }
    
    return BackupTruss(synthName, trussMap: trussMap, createFileData: .fn({ b, e in
      try defaultSysexData(b, deviceId: UInt8(RolandDefaultDeviceId), address: start, map: map).reduce([], +)
    }), parseBodyData: {
      FullRefTruss.sysexibles(fileData: $0, trussMap: trussMap, pathForData: {
        path(forData: $0, start: start, sysexWerk: sysexWerk, map: map)
      })
    }, otherValidSizes: otherValidSizes)
  }
}


//  // MARK: Compact data
//
//  static func addressables(forCompactData data: Data) -> [SynthPath:Sysexible] {
//    // if there's more than one sysex msg, we need to:
//    // sort them by base address
//    let sortedMsgs = SysexData(data: data).sorted { return address(forSysex: $0) < address(forSysex: $1) }
//    // concat the meat of the sysex msgs (stuff without header and footer)
//    let meat = sortedMsgs.map { $0[dataSetHeaderCount..<($0.count-2)] }.reduce(Data(), +)
//    // then iterate through it, making subpatches
//    var dataIndex = 0
//
//    return rolandMap.sorted { $0.address < $1.address }.dictionary {
//      let subdataMeatCount = $0.sysex.fileDataCount - (dataSetHeaderCount + 2)
//      let meatRange = dataIndex..<(dataIndex + subdataMeatCount)
//      guard meatRange.endIndex <= meat.count else { return [:] }
//      dataIndex += subdataMeatCount
//
//      let subdata = dataSetHeaderCount.map { 0 } + [UInt8](meat[meatRange]) + [0, 0]
//      return [$0.path : $0.sysex.templatedSysexType.init(data: Data(subdata))]
//    }
//  }
//
//  /// The size of a sysex file for this patch when stored in compact format (256 data bytes per msg except last)
//  static var compactFileDataCount: Int {
//    // the realsize of all the subpatches put together, plus header and footer
//    let msgHeadFoot = dataSetHeaderCount + 2 // extra data per message
//    let msgCount = Int(ceil(Float(realSize) / 256)) // the number of msgs this will need to be split into
//    return realSize + (msgCount * msgHeadFoot)
//  }

