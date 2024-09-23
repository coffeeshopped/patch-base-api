
public struct RolandOffsetAddressIso {
  public let address: (_ location: UInt8) -> RolandAddress
  public let location: (_ address: RolandAddress) -> UInt8
  
  public init(address: @escaping (_ location: UInt8) -> RolandAddress, location: @escaping (_ address: RolandAddress) -> UInt8) {
    self.address = address
    self.location = location
  }
}

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
//        let a = address + iso.address(UInt8(index))
        return try patchWerk.sysexData(werk)(bd, e, start)
      }))

//      try createFileFn(b, UInt8(RolandDefaultDeviceId), start, patchWerk, iso).reduce([], +)
    }), parseBodyData: defaultParseBodyData(werk, start: start), validBundle: validBundle)
  }
  
  public func anyTruss(_ werk: RolandSysexTrussWerk, start: RolandAddress) throws -> any SysexTruss {
    try truss(werk, start: start)
  }
}

public extension RolandMultiBankTrussWerk {
  
  func defaultParseBodyData(_ werk: RolandSysexTrussWerk, start: RolandAddress) -> MultiBankTruss.Core.ParseBodyDataFn {
    
    return { fileData in
      let patchTruss = try patchWerk.truss(werk, start: start)
      let locationBlock: ([UInt8]) -> Int? = {
        Int(iso.location(werk.address(forSysex: $0)))
      }
      let sysex = SysexData(data: Data(fileData))
      // patches can be multiple sysex messages
      // so first put together the data in chunks, then make patches from it
      var sysexDict = [Int : [UInt8]]()
      sysex.forEach { d in
        guard let location = locationBlock(d.bytes()) else { return }
        if sysexDict[location] == nil {
          sysexDict[location] = d.bytes()
        }
        else {
          sysexDict[location]?.append(contentsOf: d.bytes())
        }
      }
      return try (0..<patchCount).map {
        guard let d = sysexDict[$0] else { return try patchTruss.createInitBodyData() }
        return try patchTruss.parseBodyData(d)
      }
    }
  }
  
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
  
//  public var werk: RolandSysexTrussWerk { patchWerk.werk }
  
//  public var anyTruss: any SysexTruss { truss }

//  public func anySysexData(_ bodyData: SysexBodyData, deviceId: UInt8, address: RolandAddress) throws -> [[UInt8]] {
//    let bd = try bodyDataCheck(bodyData, bodyDataType: BodyData.self)
//    return Self.defaultCreateFileData(bd, deviceId: deviceId, address: address, patchWerk: self.patchWerk, iso: self.iso)
//  }

}
