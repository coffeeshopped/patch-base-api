
public typealias RolandSinglePatchSysexDataFn = (_ bytes: SinglePatchTruss.BodyData, _ dataSetHeader: [UInt8], _ address: RolandAddress, _ addressCount: Int) -> [[UInt8]]


public struct RolandSinglePatchTrussWerk : RolandPatchTrussWerk {
  public typealias BodyData = SinglePatchTruss.BodyData

  public typealias SysexDataFn = (_ bytes: BodyData, _ deviceId: UInt8, _ address: RolandAddress) -> [[UInt8]]
  
//  public let werk: RolandSysexTrussWerk
  public let start: RolandAddress
  public let size: RolandAddress

//  public let truss: SinglePatchTruss
  public let sysexDataFn: SinglePatchTruss.Core.ToMidiFn?

  public init(_ displayId: String, _ params: SynthPathParam, size: RolandAddress, start: RolandAddress, name: NamePackIso? = nil, initFile: String = "", defaultName: String? = nil, sysexDataFn: SinglePatchTruss.Core.ToMidiFn? = nil, randomize: SinglePatchTruss.RandomizeFn? = nil) throws {
//    self.werk = werk
    self.start = start
    self.size = size
//    let sysexDataFn = sysexDataFn ?? {
//      [werk.sysexMsg(deviceId: $1, address: $2, bytes: $0)]
//    }
    self.sysexDataFn = sysexDataFn

    
    let bodyDataCount = size.intValue()
//    let parseBodyData = SinglePatchTruss.parseBodyDataFn(parseOffset: werk.parseOffset, bodyDataCount: bodyDataCount)
    
    // valid sizes should be based on both passed in size as well as the default createFileData
//    self.truss = try SinglePatchTruss(displayId, bodyDataCount, namePackIso: name, params: params, initFile: initFile, defaultName: defaultName, createFileData: .fn({ b, e in
//      sysexDataFn(b, UInt8(RolandDefaultDeviceId), start).reduce([], +)
//    }), parseBodyData: parseBodyData, validSizes: [werk.sysexMsgCount(size: size)], includeFileDataCount: true, pack: Self.defaultPack, unpack: Self.defaultUnpack, randomize: randomize)
  }
  
}

extension RolandSinglePatchTrussWerk : AnyRolandSysexTrussWerk {
  
//  public var anyTruss: any SysexTruss { truss }

//  public func anySysexData(_ bodyData: SysexBodyData, deviceId: UInt8, address: RolandAddress) throws -> [[UInt8]] {
//    let bd = try bodyDataCheck(bodyData, bodyDataType: BodyData.self)
//    return self.sysexDataFn(bd, deviceId, address)
//  }

  /// Param parm > 1 -> multi-byte parameter
  static func defaultUnpack(bodyData: BodyData, param: Parm) -> Int? {
    let byteCount = param.p!
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
    let byteCount = param.p!
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
//
////patchT: @escaping MidiTransform.Whole<PatchTruss>,
////nameT: MidiTransform.Name<PatchTruss>? = nil
//
//}
