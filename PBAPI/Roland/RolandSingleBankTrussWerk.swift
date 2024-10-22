
public struct RolandSingleBankTrussWerk {
  public typealias BodyData = SingleBankTruss.BodyData

  public typealias ParseBodyFn = (_ fileData: [UInt8], _ iso: RolandOffsetAddressIso, _ patchWerk: RolandSinglePatchTrussWerk, _ patchCount: Int) throws -> BodyData

  public let start: RolandAddress
  public let size: RolandAddress
  
  let patchWerk: RolandSinglePatchTrussWerk
  public let iso: RolandOffsetAddressIso
  
  public init(_ patchWerk: RolandSinglePatchTrussWerk, _ patchCount: Int, start: RolandAddress, initFile: String = "", defaultName: String? = nil, iso: RolandOffsetAddressIso, parseBodyFn: ParseBodyFn? = nil, validBundle: ValidBundle? = nil) {
    self.patchWerk = patchWerk
    self.iso = iso
    self.start = start
        
    self.size = iso.address(UInt8(patchCount - 1)) + patchWerk.size

//    let parseBodyFn = parseBodyFn ?? Self.defaultParseBodyData
    
//    self.truss = SingleBankTruss(patchTruss: patchWerk.truss, patchCount: patchCount, initFile: initFile, defaultName: defaultName, createFileData: .fn({ b, e in
//      Self.defaultSysexData(b, deviceId: UInt8(RolandDefaultDeviceId), address: start, patchWerk: patchWerk, iso: iso).reduce([], +)
//    }), parseBodyData: { fileData in
//      try parseBodyFn(fileData, iso, patchWerk, patchCount)
//    }, validBundle: validBundle)
  }
  
  public func anyTruss(_ werk: RolandSysexTrussWerk, start: RolandAddress) throws -> any SysexTruss {
    fatalError("TODO")
  }

}

public extension RolandSingleBankTrussWerk {
  
//  static func defaultParseBodyData(fileData: [UInt8], iso: RolandOffsetAddressIso, patchWerk: RolandSinglePatchTrussWerk, patchCount: Int) throws -> BodyData {
//    
//    let patchTruss = patchWerk.truss
//    let locationBlock: ([UInt8]) -> Int? = {
//      Int(iso.location(patchWerk.werk.address(forSysex: $0)))
//    }
//    let sysex = SysexData(data: Data(fileData))
//    // patches can be multiple sysex messages
//    // so first put together the data in chunks, then make patches from it
//    var sysexDict = [Int : [UInt8]]()
//    sysex.forEach { d in
//      guard let location = locationBlock(d.bytes()) else { return }
//      if sysexDict[location] == nil {
//        sysexDict[location] = d.bytes()
//      }
//      else {
//        sysexDict[location]?.append(contentsOf: d.bytes())
//      }
//    }
//    return try (0..<patchCount).map {
//      guard let d = sysexDict[$0] else { return try patchTruss.createInitBodyData() }
//      return try patchTruss.parseBodyData(d)
//    }
//  }
  
//  static func defaultSysexData(_ bodyData: BodyData, deviceId: UInt8, address: RolandAddress, patchWerk: RolandSinglePatchTrussWerk, iso: RolandOffsetAddressIso) -> [[UInt8]] {
//    bodyData.enumerated().map({ (index, bd) in
//      let a = address + iso.address(UInt8(index))
//      return patchWerk.sysexDataFn(bd, deviceId, a)
//    }).reduce([], +)
//  }
  
  func containsOffset(address: RolandAddress) -> Bool { address < size }

  
  // MARK: Compact data
  
//  static func defaultParseCompactBodyData(fileData: [UInt8], iso: RolandOffsetAddressIso, patchWerk: RolandSinglePatchTrussWerk, patchCount: Int) throws -> BodyData {
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

extension RolandSingleBankTrussWerk : AnyRolandSysexTrussWerk {
  
//  public var werk: RolandSysexTrussWerk { patchWerk.werk }
  
//  public var anyTruss: any SysexTruss { truss }

//  public func anySysexData(_ bodyData: SysexBodyData, deviceId: UInt8, address: RolandAddress) throws -> [[UInt8]] {
//    let bd = try bodyDataCheck(bodyData, bodyDataType: BodyData.self)
//    return Self.defaultSysexData(bd, deviceId: deviceId, address: address, patchWerk: self.patchWerk, iso: self.iso)
//  }

}


//public protocol RolandSingleBankTrussBuilder : RolandBankTrussBuilder, SingleBankTrussBuilder {
//    
//  /// This method is also declared in RolandMultiBankTrussBuilder. It would be nice to move this declaration up to RolandBankTrussBuilder without entering the land of AssociatedType constraint errors.
////  static func sysexData(_ bodyData: BankTruss.BodyData, deviceId: UInt8, address: RolandAddress) -> [[UInt8]]
//
//}
//
//public extension RolandSingleBankTrussBuilder  {
////  
////  static var size: RolandAddress {
////    offsetAddress(location: UInt8(patchCount - 1)) + PatchBuilder.size
////  }
////  
////  static var realSize: Int { patchCount * PatchBuilder.realSize }
////
//}
