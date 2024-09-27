
public struct RolandMultiBankTrussWerk {
  public typealias BodyData = MultiBankTruss.BodyData

  public typealias CreateFileFn = (_ bodyData: BodyData, _ deviceId: UInt8, _ address: RolandAddress, _ patchWerk: RolandMultiPatchTrussWerk, _ iso: RolandOffsetAddressIso) throws -> [[UInt8]]

  public let size: RolandAddress
  public let patchCount: Int
  let initFile: String
  let validBundle: MultiBankTruss.Core.ValidBundle?  
  let patchWerk: RolandMultiPatchTrussWerk
  public let iso: RolandOffsetAddressIso
  
  public init(_ patchWerk: RolandMultiPatchTrussWerk, _ patchCount: Int, initFile: String = "", iso: RolandOffsetAddressIso, createFileFn: CreateFileFn? = nil, validBundle: MultiBankTruss.Core.ValidBundle? = nil) {
    self.patchWerk = patchWerk
    self.iso = iso
    self.size = iso.address(UInt8(patchCount - 1)) + patchWerk.size
    self.patchCount = patchCount
    self.initFile = initFile
    self.validBundle = validBundle
  }
  
  public func truss(_ werk: RolandSysexTrussWerk, start: RolandAddress) throws -> MultiBankTruss {
//    let createFileFn = /*createFileFn ??*/ Self.defaultCreateFileData
        
    return MultiBankTruss(patchTruss: try patchWerk.truss(werk, start: start), patchCount: patchCount, initFile: initFile, createFileData: .fn({ b, e in
      .arr(try b.enumerated().flatMap({ (index, bd) in
        try patchWerk.sysexData(werk)(bd, e, start + iso.address(UInt8(index)))
      }))

//      try createFileFn(b, UInt8(RolandDefaultDeviceId), start, patchWerk, iso).reduce([], +)
    }), parseBodyData: { fileData in
      let rData = RolandWerkData(data: Data(fileData), werk: werk)
      return patchCount.map {
        let address = iso.address(UInt8($0))
        return patchWerk.parseBodyData(rData, address)
      }
    }, validBundle: validBundle)
  }
  
  public func anyTruss(_ werk: RolandSysexTrussWerk, start: RolandAddress) throws -> any SysexTruss {
    try truss(werk, start: start)
  }
}

public extension RolandMultiBankTrussWerk {
    
//  static func defaultCreateFileData(_ bodyData: BodyData, deviceId: UInt8, address: RolandAddress, patchWerk: RolandMultiPatchTrussWerk, iso: RolandOffsetAddressIso) -> [[UInt8]] {
//    bodyData.enumerated().map({ (index, bd) in
//      let a = address + iso.address(UInt8(index))
//      return patchWerk.sysexDataFn.call(bd, /*deviceId, a*/)
//    }).reduce([], +)
//  }
  
  func containsOffset(address: RolandAddress) -> Bool { address < size }

  
  // MARK: Compact data
  
//  static func defaultParseCompactBodyData(fileData: [UInt8], iso: RolandOffsetAddressIso, patchWerk: RolandMultiPatchTrussWerk, patchCount: Int) throws -> BodyData {
//    
//    let rData = RolandWerkData(data: Data(fileData), werk: patchWerk.werk)
//    return try (0..<patchCount).map {
//      let patchData = rData.bytes(offset: iso.address(UInt8($0)), size: patchWerk.size)
//      let subdata = patchWerk.werk.dummySysex(bytes: patchData)
//      return try patchWerk.truss.parseBodyData(subdata)
//    }
//
//  }
  
}

extension RolandMultiBankTrussWerk : AnyRolandSysexTrussWerk {
  
//  public func anySysexData(_ bodyData: SysexBodyData, deviceId: UInt8, address: RolandAddress) throws -> [[UInt8]] {
//    let bd = try bodyDataCheck(bodyData, bodyDataType: BodyData.self)
//    return Self.defaultCreateFileData(bd, deviceId: deviceId, address: address, patchWerk: self.patchWerk, iso: self.iso)
//  }

}
