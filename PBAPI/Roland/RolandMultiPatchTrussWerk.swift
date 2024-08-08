
public typealias RolandMultiPatchSysexDataFn = (_ bytes: MultiPatchTruss.BodyData, _ dataSetHeader: [UInt8], _ address: RolandAddress, _ addressCount: Int) -> [[UInt8]]


public struct RolandMultiPatchTrussWerk : RolandPatchTrussWerk {
  public typealias BodyData = MultiPatchTruss.BodyData
  public typealias MapItem = (path: SynthPath, address: RolandAddress, werk: RolandSinglePatchTrussWerk)
  public typealias SysexDataFn = (_ bytes: BodyData, _ deviceId: UInt8, _ address: RolandAddress) -> [[UInt8]]
  
  public typealias ParseBodyFn = (_ fileData: [UInt8], _ werk: RolandSysexTrussWerk, _ map: [MapItem]) throws -> BodyData

  public let werk: RolandSysexTrussWerk
  public let start: RolandAddress
  public let size: RolandAddress
  
  public let map: [MapItem]
  public let truss: MultiPatchTruss
  public let sysexDataFn: SysexDataFn
  
  public let dict: [SynthPath:(address: RolandAddress, werk: RolandSinglePatchTrussWerk)]

  public init(_ werk: RolandSysexTrussWerk, _ displayId: String, _ map: [MapItem], start: RolandAddress, initFile: String = "", parseBodyFn: ParseBodyFn? = nil, sysexDataFn: SysexDataFn? = nil, validBundle bundle: MultiPatchTruss.Core.ValidBundle? = nil) {
    self.werk = werk
    self.map = map
    self.start = start
    
    self.dict = map.dict(transform: { [$0.path : ($0.address, $0.werk)]} )
    // TODO: at some point might need to make size be something that can be passed in.
    // take the largest address, and add the size of the corresponding subpatch
    if let maxItem = map.sorted(by: { $0.address > $1.address }).first {
      self.size = maxItem.address + maxItem.werk.size
    }
    else {
      self.size = 0
    }
    
    let sysexDataFn = sysexDataFn ?? { bodyData, deviceId, address in
      map.compactMap {
        guard let bd = bodyData[$0.path] else { return nil }
        return $0.werk.sysexDataFn(bd, deviceId, $0.address + address)
      }.reduce([], +)
    }
    self.sysexDataFn = sysexDataFn
    
    let parseBodyFn = parseBodyFn ?? Self.defaultParseBodyData
    self.truss = MultiPatchTruss(displayId, trussMap: map.map { ($0.path, $0.werk.truss) }, namePath: [.common], initFile: initFile, createFileData: { b, e in
      sysexDataFn(b, UInt8(RolandDefaultDeviceId), start).reduce([], +)
    }, parseBodyData: {
      try parseBodyFn($0, werk, map)
    }, validBundle: bundle)
  }
  
}

extension RolandMultiPatchTrussWerk : AnyRolandSysexTrussWerk {

  public var anyTruss: any SysexTruss { truss }

  public func anySysexData(_ bodyData: SysexBodyData, deviceId: UInt8, address: RolandAddress) throws -> [[UInt8]] {
    let bd = try bodyDataCheck(bodyData, bodyDataType: BodyData.self)
    return self.sysexDataFn(bd, deviceId, address)
  }

}

public extension RolandMultiPatchTrussWerk {
    
  static func defaultParseBodyData(_ fileData: [UInt8], werk: RolandSysexTrussWerk, map: [MapItem]) throws -> BodyData {
    let sysex = SysexData(data: Data(fileData))

    // determine the base address of the fetched data
    let baseAdd = sysex.map { werk.address(forSysex: $0.bytes()) }.sorted(by: { $0 < $1 }).first
    guard let baseAddress = baseAdd else {
      // if no base address found, init subpatches
      var d = BodyData()
      try map.forEach {
        d[$0.path] = try $0.werk.truss.createInitBodyData()
      }
      return d
    }
    
    var subpatchData = [Int:[UInt8]]()
    sysex.forEach { msg in
      let offsetAddress = werk.address(forSysex: msg.bytes()) - baseAddress
      // find key that matches the offset address
      guard let index = mapIndex(address: offsetAddress, sysex: msg.bytes(), map: map) else { return }
      subpatchData[index] = (subpatchData[index] ?? []) + msg
    }

    var p = BodyData()
    try subpatchData.forEach { (index, data) in
      let item = map[index]
      p[item.path] = try item.werk.truss.parseBodyData(data)
    }

    // for any unfilled subpatches, init them
    try map.forEach {
      guard p[$0.path] == nil else { return }
      p[$0.path] = try $0.werk.truss.createInitBodyData()
    }

    return p
  }
  
  static func mapIndex(address: RolandAddress, sysex: [UInt8], map: [MapItem]) -> Int? {
    map.enumerated().first { i, item in
      if address == item.address,
         item.werk.truss.isValidFileData(sysex) {
        return true
      }
//      else if let template = builder as? RolandMultiPatchTemplate.Type,
//              template.mapIndex(address: address - item.address, sysex: sysex) != nil {
//        return true
//      }
      return false
    }?.offset
  }
  
  func mapIndex(address: RolandAddress, sysex: [UInt8]) -> Int? {
    Self.mapIndex(address: address, sysex: sysex, map: map)
  }
  
  // MARK: Compact data
  
  static func defaultParseCompactBodyData(_ fileData: [UInt8], werk: RolandSysexTrussWerk, map: [MapItem]) throws -> BodyData {
    
    let rData = RolandWerkData(data: Data(fileData), werk: werk)
    return map.dict {
      let patchData = rData.bytes(offset: $0.address, size: $0.werk.size)
      let subdata = werk.dummySysex(bytes: patchData)
      return [$0.path : try! $0.werk.truss.parseBodyData(subdata)]
    }
  }

  //  /// The size of a sysex file for this patch when stored in compact format (256 data bytes per msg except last)
  //  static var compactFileDataCount: Int {
  //    // the realsize of all the subpatches put together, plus header and footer
  //    let msgHeadFoot = dataSetHeaderCount + 2 // extra data per message
  //    let msgCount = Int(ceil(Float(realSize) / 256)) // the number of msgs this will need to be split into
  //    return realSize + (msgCount * msgHeadFoot)
  //  }
    
}

//public protocol RolandMultiPatchTrussBuilder : MultiPatchTrussBuilder, RolandPatchTrussBuilder {
//  
////  static var rolandMap: RolandSinglePatchTrussMapper { get }
////  static func mapIndex(address: RolandAddress, sysex: [UInt8]) -> Int?
//
//}
//
//public extension RolandMultiPatchTrussBuilder {
//  
////  static func rolandCreatePatchTruss() -> PatchTruss {
////    var t = defaultCreatePatchTruss()
////    t.parseBodyData = defaultParseBodyData
////    t.createFileData = {
////      sysexData($0, deviceId: UInt8(RolandDefaultDeviceId), address: startAddress(nil)).reduce([], +)
////    }
////    // TODO: valid checks?
////    return t
////  }
//  
//  static func mapper(_ items: [RolandSinglePatchTrussMapItem]) -> RolandSinglePatchTrussMapper {
//    RolandSinglePatchTrussMapper(items)
//  }
//  
////  static var builderMap: [(SynthPath, SinglePatchTrussBuilder.Type)] { rolandMap.builderMap }
////  
////  static var trussMap: [(SynthPath, SinglePatchTruss)] { rolandMap.trussMap }
////  
////  static func mapItem(path: SynthPath) -> RolandSinglePatchTrussMapItem? {
////    rolandMap.mapItem(path: path)
////  }
////
////  static var namePath: SynthPath? { [.common] }
////  
////  static var realSize: Int { rolandMap.realSize }
////  
//
//  
//  static func mapIndex(address: RolandAddress, sysex: [UInt8], rolandMap: RolandSinglePatchTrussMapper) -> Int? {
//    rolandMap.items.enumerated().first { i, item in
//      let builder = item.builder
//      if address == item.address,
//         builder.patchTruss.isValidFileData(sysex) {
//        return true
//      }
////      else if let template = builder as? RolandMultiPatchTemplate.Type,
////              template.mapIndex(address: address - item.address, sysex: sysex) != nil {
////        return true
////      }
//      return false
//    }?.offset
////    for (i, item) in rolandMap.enumerated() {
////      if address == item.address,
////         item.builder is RolandSinglePatchTemplate.Type,
////         item.builder.isValid(sysex: sysex) {
////        return i
////      }
////      else if let template = item.builder as? RolandMultiPatchTemplate.Type,
////              template.mapIndex(address: address - item.address, sysex: sysex) != nil {
////        return i
////      }
////    }
////    return nil
//  }
