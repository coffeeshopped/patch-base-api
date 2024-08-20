
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

  public typealias ParseBodyFn = (_ fileData: [UInt8], _ iso: RolandOffsetAddressIso, _ patchWerk: RolandMultiPatchTrussWerk, _ patchCount: Int) throws -> BodyData

  public let start: RolandAddress
  public let size: RolandAddress
  
  public let truss: MultiBankTruss
  let patchWerk: RolandMultiPatchTrussWerk
  public let iso: RolandOffsetAddressIso
  
  public init(_ patchWerk: RolandMultiPatchTrussWerk, _ patchCount: Int, start: RolandAddress, initFile: String = "", iso: RolandOffsetAddressIso, createFileFn: CreateFileFn? = nil, parseBodyFn: ParseBodyFn? = nil, validBundle: MultiBankTruss.Core.ValidBundle? = nil) {
    self.patchWerk = patchWerk
    self.iso = iso
    self.start = start
        
    self.size = iso.address(UInt8(patchCount - 1)) + patchWerk.size

    let parseBodyFn = parseBodyFn ?? Self.defaultParseBodyData
    let createFileFn = createFileFn ?? Self.defaultCreateFileData
    
    self.truss = MultiBankTruss(patchTruss: patchWerk.truss, patchCount: patchCount, initFile: initFile, createFileData: .fn({ b, e in
      try createFileFn(b, UInt8(RolandDefaultDeviceId), start, patchWerk, iso).reduce([], +)
    }), parseBodyData: { fileData in
      try parseBodyFn(fileData, iso, patchWerk, patchCount)
    }, validBundle: validBundle)
  }
  
}

public extension RolandMultiBankTrussWerk {
  
  static func defaultParseBodyData(fileData: [UInt8], iso: RolandOffsetAddressIso, patchWerk: RolandMultiPatchTrussWerk, patchCount: Int) throws -> BodyData {
    
    let patchTruss = patchWerk.truss
    let locationBlock: ([UInt8]) -> Int? = {
      Int(iso.location(patchWerk.werk.address(forSysex: $0)))
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
  
  static func defaultCreateFileData(_ bodyData: BodyData, deviceId: UInt8, address: RolandAddress, patchWerk: RolandMultiPatchTrussWerk, iso: RolandOffsetAddressIso) -> [[UInt8]] {
    bodyData.enumerated().map({ (index, bd) in
      let a = address + iso.address(UInt8(index))
      return patchWerk.sysexDataFn(bd, deviceId, a)
    }).reduce([], +)
  }
  
  func containsOffset(address: RolandAddress) -> Bool { address < size }

  
  // MARK: Compact data
  
  static func defaultParseCompactBodyData(fileData: [UInt8], iso: RolandOffsetAddressIso, patchWerk: RolandMultiPatchTrussWerk, patchCount: Int) throws -> BodyData {
    
    let rData = RolandWerkData(data: Data(fileData), werk: patchWerk.werk)
    return try (0..<patchCount).map {
      let patchData = rData.bytes(offset: iso.address(UInt8($0)), size: patchWerk.size)
      let subdata = patchWerk.werk.dummySysex(bytes: patchData)
      return try patchWerk.truss.parseBodyData(subdata)
    }

  }
  
}

extension RolandMultiBankTrussWerk : AnyRolandSysexTrussWerk {
  
  public var werk: RolandSysexTrussWerk { patchWerk.werk }
  
  public var anyTruss: any SysexTruss { truss }

  public func anySysexData(_ bodyData: SysexBodyData, deviceId: UInt8, address: RolandAddress) throws -> [[UInt8]] {
    let bd = try bodyDataCheck(bodyData, bodyDataType: BodyData.self)
    return Self.defaultCreateFileData(bd, deviceId: deviceId, address: address, patchWerk: self.patchWerk, iso: self.iso)
  }

}
