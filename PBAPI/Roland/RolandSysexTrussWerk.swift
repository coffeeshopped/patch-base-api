
/// Contains the basic sysex structure for a Roland synth. Often applicable to an entire family of synths.
public struct RolandSysexTrussWerk {
  
  public let modelId: [UInt8]
  public let addressCount: Int
  public let dataSetHeaderCount: Int
  public let dataSetHeader: (_ deviceId: UInt8) -> [UInt8]
  public let parseOffset: Int

  public init(modelId: [UInt8], addressCount: Int) {
    self.modelId = modelId
    self.addressCount = addressCount
    self.dataSetHeader = { [0xf0, 0x41, $0] + modelId + [0x12] }
    self.dataSetHeaderCount = dataSetHeader(UInt8(RolandDefaultDeviceId)).count
    self.parseOffset = dataSetHeaderCount + addressCount
  }
  
}

public extension RolandSysexTrussWerk {

  func checksum(address: RolandAddress, dataBytes data: [UInt8]) -> UInt8 {
    RolandChecksum(address: address, dataBytes: data, addressCount: addressCount)
  }

  func addressBytes(forSysex sysex: [UInt8]) -> [UInt8] {
    guard sysex.count >= dataSetHeaderCount + addressCount else { return [] }
    return Array(sysex[dataSetHeaderCount..<(dataSetHeaderCount+addressCount)])
  }

  func address(forSysex sysex: [UInt8]) -> RolandAddress {
    RolandAddress(addressBytes(forSysex: sysex))
  }

//  func sysexMsg(deviceId: UInt8, rolandData: RolandData, address: RolandAddress, size: RolandAddress) -> [UInt8] {
//    let bytes = [UInt8](rolandData.data(forAddress: address, size: size))
//    return sysexMsg(deviceId: deviceId, address: address, bytes: bytes)
//  }
  
  // the length of a sysex msg given a size (e.g. size specified in Roland docs)
  func sysexMsgCount(size: RolandAddress) -> Int {
    dataSetHeaderCount + addressCount + size.intValue() + 2
  }
  
  func sysexMsg(deviceId: UInt8, address: RolandAddress, bytes: [UInt8]) -> [UInt8] {
    dataSetHeader(deviceId) + address.sysexBytes(count: addressCount) + bytes +
    [checksum(address: address, dataBytes: bytes), 0xf7]
  }
  
  /// Used to take some parsed content data and make a sysex msg out of it to pass to parse func (e.g. compact data)
  func dummySysex(bytes: [UInt8]) -> [UInt8] {
    sysexMsg(deviceId: UInt8(RolandDefaultDeviceId), address: 0x0, bytes: bytes)
  }
  
  func paramSetData(_ bytes: [UInt8], deviceId: UInt8, address: RolandAddress, path: SynthPath, params: SynthPathParam) -> [UInt8] {
    guard let param = params[path],
      param.b! >= 0 else { return [] } // deviceId param is byte: -1... probably not needed now.
    let byte = RolandAddress(param.b!).intValue() // param.byte should be roland address
    let paramAddress = address + RolandAddress(param.b!)
    let byteCount = param.packIso?.byteCount ?? 1
    let valueBytes = Array(bytes[byte..<(byte + byteCount)])
    return dataSetHeader(deviceId) + paramAddress.sysexBytes(count: addressCount) + valueBytes + [checksum(address: paramAddress, dataBytes: valueBytes), 0xf7]
  }
  
  func nameSetData(_ bytes: [UInt8], deviceId: UInt8, address: RolandAddress, namePackIso: NamePackIso) -> [UInt8] {
    let nameAddress = address + RolandAddress(intValue: namePackIso.byteRange.lowerBound)
    let nameBytes = Array(bytes[namePackIso.byteRange])
    return dataSetHeader(deviceId) + nameAddress.sysexBytes(count: addressCount) + nameBytes + [checksum(address: nameAddress, dataBytes: nameBytes), 0xf7]
  }
    
//  func singlePatchWerk(_ displayId: String, _ params: SynthPathParam, size: RolandAddress, start: RolandAddress, name: NamePackIso? = nil, initFile: String = "", defaultName: String? = nil, sysexDataFn: RolandSinglePatchTrussWerk.SysexDataFn? = nil, randomize: SinglePatchTruss.RandomizeFn? = nil) throws -> RolandSinglePatchTrussWerk {
//    try RolandSinglePatchTrussWerk(self, displayId, params, size: size, start: start, name: name, initFile: initFile, defaultName: defaultName, sysexDataFn: sysexDataFn, randomize: randomize)
//  }
  
  func singleBankWerk(_ patchWerk: RolandSinglePatchTrussWerk, _ patchCount: Int, start: RolandAddress, initFile: String? = nil, iso: RolandOffsetAddressIso? = nil, validBundle: SingleBankTruss.Core.ValidBundle? = nil) -> RolandSingleBankTrussWerk {
    let iso = iso ?? .init(address: {
      RolandAddress([$0, 0, 0])
    }, location: {
      $0.sysexBytes(count: addressCount)[1]
    })
    return RolandSingleBankTrussWerk(patchWerk, patchCount, start: start, iso: iso, validBundle: validBundle)
  }
  
//  func compactSingleBankWerk(_ patchWerk: RolandSinglePatchTrussWerk, _ patchCount: Int, start: RolandAddress, initFile: String? = nil, defaultName: String? = nil, iso: RolandOffsetAddressIso? = nil, validBundle: SingleBankTruss.Core.ValidBundle? = nil) -> RolandSingleBankTrussWerk {
//    let iso = iso ?? .init(address: {
//      RolandAddress([$0, 0, 0])
//    }, location: {
//      $0.sysexBytes(count: addressCount)[1]
//    })
//    return RolandSingleBankTrussWerk(patchWerk, patchCount, start: start, initFile: initFile ?? "", defaultName: defaultName, iso: iso, parseBodyFn: RolandSingleBankTrussWerk.defaultParseCompactBodyData, validBundle: validBundle)
//  }
//
//  
//  func multiPatchWerk(_ displayId: String, _ map: [RolandMultiPatchTrussWerk.MapItem], start: RolandAddress, initFile: String = "", sysexDataFn: RolandMultiPatchTrussWerk.SysexDataFn? = nil, validBundle: MultiPatchTruss.Core.ValidBundle? = nil) -> RolandMultiPatchTrussWerk {
//    RolandMultiPatchTrussWerk(self, displayId, map, start: start, initFile: initFile, sysexDataFn: sysexDataFn, validBundle: validBundle)
//  }
//
//  func compactMultiPatchWerk(_ displayId: String, _ map: [RolandMultiPatchTrussWerk.MapItem], start: RolandAddress, initFile: String = "", sysexDataFn: RolandMultiPatchTrussWerk.SysexDataFn? = nil, validBundle: MultiPatchTruss.Core.ValidBundle? = nil) -> RolandMultiPatchTrussWerk {
//    RolandMultiPatchTrussWerk(self, displayId, map, start: start, initFile: initFile, parseBodyFn: RolandMultiPatchTrussWerk.defaultParseCompactBodyData, sysexDataFn: sysexDataFn, validBundle: validBundle)
//  }

  
  func multiBankWerk(_ patchWerk: RolandMultiPatchTrussWerk, _ patchCount: Int, start: RolandAddress, initFile: String? = nil, iso: RolandOffsetAddressIso? = nil, validBundle: MultiBankTruss.Core.ValidBundle? = nil) -> RolandMultiBankTrussWerk {
    let iso = iso ?? .init(address: {
      RolandAddress([$0, 0, 0])
    }, location: {
      $0.sysexBytes(count: addressCount)[1]
    })
    return RolandMultiBankTrussWerk(patchWerk, patchCount, start: start, iso: iso, validBundle: validBundle)
  }
  
//  func compactMultiBankWerk(_ patchWerk: RolandMultiPatchTrussWerk, _ patchCount: Int, start: RolandAddress, initFile: String? = nil, iso: RolandOffsetAddressIso? = nil, validBundle: MultiBankTruss.Core.ValidBundle? = nil) -> RolandMultiBankTrussWerk {
//    let iso = iso ?? .init(address: {
//      RolandAddress([$0, 0, 0])
//    }, location: {
//      $0.sysexBytes(count: addressCount)[1]
//    })
//    return RolandMultiBankTrussWerk(patchWerk, patchCount, start: start, iso: iso, parseBodyFn: RolandMultiBankTrussWerk.defaultParseCompactBodyData, validBundle: validBundle)
//  }
  
  func editorWerk(_ name: String, deviceId: EditorValueTransform? = nil, map: [RolandEditorTrussWerk.MapItem]) -> RolandEditorTrussWerk {
    let deviceId = deviceId ?? .value([.deviceId], [.deviceId], defaultValue: RolandDefaultDeviceId)
    return RolandEditorTrussWerk(name, map, deviceId: deviceId, sysexWerk: self)
  }


}


//public protocol RolandSysexTrussBuilder : SysexTrussBuilder {
//  
////  // this is "size" as in the docs, but isn't actual data size
////  /// For RolandMulti's, The size (in roland address bytes) of the whole patch. Used for fetching
////  static var size: RolandAddress { get }
////
////  /// The address in memory for this patch type, based on a path. Used for fetching edit buffers (Patch mode and Parts)
////  static func startAddress(_ path: SynthPath?) -> RolandAddress
////
////  // actual data size
////  static var realSize: Int { get }
////
////  /// Length of address in bytes
////  static var addressCount: Int { get }
////  /// Length of data set header (including address bytes!)
////  static var dataSetHeaderCount: Int { get }
////
////  static func dataSetHeader(deviceId: UInt8) -> [UInt8]
//
//}
//
//public extension RolandSysexTrussBuilder {
//  
//  static func checksum(address: RolandAddress, dataBytes data: [UInt8], addressCount: Int) -> UInt8 {
//    RolandChecksum(address: address, dataBytes: data, addressCount: addressCount)
//  }
//  
////  static func rolandTransform(_ sysexibles: [SynthPath:Sysexible]) -> [SynthPath:RolandTemplatedSysexible] {
////    let rArr: [(SynthPath, RolandTemplatedSysexible)] = sysexibles.compactMap {
////      guard let r = $0.value as? RolandTemplatedSysexible else { return nil }
////      return ($0.key, r)
////    }
////    return rArr.dictionary { [$0.0 : $0.1] }
////  }
//
//  static func addressBytes(forSysex sysex: [UInt8], addressCount: Int, dataSetHeaderCount: Int) -> [UInt8] {
//    guard sysex.count >= dataSetHeaderCount else { return [] }
//    return Array(sysex[(dataSetHeaderCount - addressCount)..<(dataSetHeaderCount)])
//  }
//
//  static func address(forSysex sysex: [UInt8], addressCount: Int, dataSetHeaderCount: Int) -> RolandAddress {
//    RolandAddress(addressBytes(forSysex: sysex, addressCount: addressCount, dataSetHeaderCount: dataSetHeaderCount))
//  }
//
//  static func sysexMsg(dataSetHeader: [UInt8], rolandData: RolandData, address: RolandAddress, addressCount: Int, size: RolandAddress) -> [UInt8] {
//    let bytes = [UInt8](rolandData.data(forAddress: address, size: size))
//    return sysexMsg(dataSetHeader: dataSetHeader, address: address, bytes: bytes, addressCount: addressCount)
//  }
//  
//  static func sysexMsg(dataSetHeader: [UInt8], address: RolandAddress, bytes: [UInt8], addressCount: Int) -> [UInt8] {
//    dataSetHeader + address.sysexBytes(count: addressCount) + bytes +
//    [checksum(address: address, dataBytes: bytes, addressCount: addressCount), 0xf7]
//  }
//
//}
