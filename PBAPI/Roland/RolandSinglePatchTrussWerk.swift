
public struct RolandSinglePatchTrussWerk : RolandPatchTrussWerk {
  public typealias BodyData = SinglePatchTruss.BodyData

  public typealias SysexDataFn = (_ b: BodyData, _ e: AnySynthEditor?, _ address: RolandAddress) throws -> [MidiMessage]
    
  public let displayId: String
  public let parms: SynthPathParam
  public let size: RolandAddress
  public let name: NamePackIso?
  public let initFile: String
  public let defaultName: String?
  public let randomize: SinglePatchTruss.RandomizeFn?

  public init(_ displayId: String, _ parms: SynthPathParam, size: RolandAddress, name: NamePackIso? = nil, initFile: String = "", defaultName: String? = nil, randomize: SinglePatchTruss.RandomizeFn? = nil) throws {
    self.displayId = displayId
    self.parms = parms
    self.size = size
    self.name = name
    self.initFile = initFile
    self.defaultName = defaultName
    self.randomize = randomize
  }
  
  public func truss(_ werk: RolandSysexTrussWerk, start: RolandAddress) throws -> SinglePatchTruss {
    let bodyDataCount = size.intValue()
    let parseBodyData = SinglePatchTruss.parseBodyDataFn(parseOffset: werk.parseOffset, bodyDataCount: bodyDataCount)
    
    let sysexDataFn = Self.sysexData(werk)

//     valid sizes should be based on both passed in size as well as the default createFileData
    return try SinglePatchTruss(displayId, bodyDataCount, namePackIso: name, params: parms, initFile: initFile, defaultName: defaultName, createFileData: .fn({
      try sysexDataFn($0, $1, start)
    }), parseBodyData: parseBodyData, validSizes: [werk.sysexMsgCount(size: size)], includeFileDataCount: true, pack: Self.defaultPack, unpack: Self.defaultUnpack, randomize: randomize)
  }
  
  public func anyTruss(_ werk: RolandSysexTrussWerk, start: RolandAddress) throws -> any SysexTruss {
    try truss(werk, start: start)
  }
  
  public static let deviceId: EditorValueTransform = .value([.deviceId], [.deviceId], defaultValue: RolandDefaultDeviceId)
  public static func sysexData(_ werk: RolandSysexTrussWerk) -> SysexDataFn {
    { b, e, address in
      let deviceId = try deviceId.byteValue(e)
      return [.sysex(werk.sysexMsg(deviceId: deviceId, address: address, bytes: b))]
    }
  }
}

extension RolandSinglePatchTrussWerk : AnyRolandSysexTrussWerk {
  
//  public func anySysexData(_ bodyData: SysexBodyData, deviceId: UInt8, address: RolandAddress) throws -> [[UInt8]] {
//    let bd = try bodyDataCheck(bodyData, bodyDataType: BodyData.self)
//    return self.sysexDataFn(bd, deviceId, address)
//  }

  /// Param parm > 1 -> multi-byte parameter
  static func defaultUnpack(bodyData: BodyData, param: Parm) -> Int? {
    let byteCount = param.p ?? 1
    let byte = RolandAddress(param.b!).intValue()

    guard byteCount > 1 else {
      return SinglePatchTruss.defaultUnpackedByte(byte: byte, bits: param.bits, bytes: bodyData)
    }

    guard byte + byteCount <= bodyData.count else { return nil }

    return multiByteParamInt(from: Array(bodyData[byte..<(byte+byteCount)]))
  }

  /// Param parm > 1 -> multi-byte parameter
  static func defaultPack(bodyData: inout BodyData, param: Parm, value: Int) {
    // NOTE: this multi-byte style is for JV-1080 (and beyond?)
    //  JD-800 uses all 7 bits of LSB, not just 4.
    let byteCount = param.p ?? 1
    // roland byte addresses in params are *Roland* addresses
    let byte = RolandAddress(param.b!).intValue()
    guard byteCount > 1 else {
      bodyData[byte] = SinglePatchTruss.defaultPackedByte(value: value, forParam: param, byte: bodyData[byte])
      return
    }

    let b = multiByteParamBytes(from: value, count: byteCount)
    b.enumerated().forEach { bodyData[byte+$0.offset] = $0.element }
  }

  /// Compose Int value from bytes (MSB first)
  static func multiByteParamInt(from: [UInt8]) -> Int {
    guard from.count > 1 else { return Int(from[0]) }
    return (1...from.count).reduce(0) {
      let shift = (from.count - $1) * 4
      return $0 + (Int(from[$1-1]) << shift)
    }
  }

  /// Decompose Int to bytes (4 bits at a time)
  static func multiByteParamBytes(from: Int, count: Int) -> [UInt8] {
    guard count > 0 else { return [UInt8(from)] }
    return (1...count).map {
      let shift = (count - $0) * 4
      return UInt8((from >> shift) & 0xf)
    }
  }


}


//public protocol RolandSinglePatchTrussBuilder : SinglePatchTrussBuilder, RolandPatchTrussBuilder {
//  
////  static var realSize: Int { get }
////  static var size: RolandAddress { get }
////  static func sysexData(_ bodyData: BodyData, deviceId: UInt8, address: RolandAddress) -> [[UInt8]]
////
////  /// Compose Int value from bytes (MSB first)
////  static func multiByteParamInt(from: [UInt8]) -> Int
////  /// Decompose Int to bytes (4 bits at a time)
////  static func multiByteParamBytes(from: Int, count: Int) -> [UInt8]
//
//}
//
//public extension RolandSinglePatchTrussBuilder {
//    
//  static func bodyDataCount(size: RolandAddress) -> Int { size.intValue() }
//    
//  // actual data size
////  static var realSize: Int { bodyDataCount }
//

////  static var fileDataCount: Int {
////    // should be:
////    // 5 byte header (f0, manufac, model, deviceID, set command)
////    // address bytes
////    // data
////    // checksum, end byte
////    return dataSetHeaderCount + bodyDataCount + 2
////  }
//  
//  static func contentBytes(forData data: [UInt8], dataSetHeaderCount: Int, bodyDataCount: Int) -> [UInt8] {
//    data.safeBytes(dataSetHeaderCount..<(dataSetHeaderCount + bodyDataCount))
//  }
//      
//
////  static var parseBodyDataOffset: Int { dataSetHeaderCount }
//
//}
