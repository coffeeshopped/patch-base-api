
public typealias MultiSysexTrussBodyData = [SynthPath:SysexBodyData]

public protocol MultiSysexTruss : SysexTruss where BodyData == MultiSysexTrussBodyData {
  typealias PathForDataFn = (_ data: [UInt8]) -> SynthPath?
  
  /// path to sysexible that holds name data. (e.g. Performances)
  var namePath: SynthPath? { get }
  var defaultName: String { get }

//  func createMultiSysex(fileData: [UInt8]?, name: String?) throws -> AnyMultiSysexible

  var trussPaths: [SynthPath] { get }
//  var trussMap: [(SynthPath, any SysexTruss)] { get }
//  var trussDict: [SynthPath:any SysexTruss] { get }
  
  func trussMap(fileData: [UInt8]) -> [(SynthPath, any SysexTruss)]?
  func trussMap(bodyData: SysexBodyData) -> [(SynthPath, any SysexTruss)]?

}

public extension MultiSysexTruss {

  func sysexBodyData(_ data: BodyData) -> SysexBodyData {
    .multiSysex(data)
  }

  func synthPath(forSection section: Int) -> SynthPath? {
    guard section < trussPaths.count else { return nil }
    return trussPaths[section]
  }


//  func fileData(_ dataDict: [SynthPath:Any]) throws -> [UInt8] {
//    // map over the types to ensure ordering of data
//    return try trussMap.compactMap {
//      switch $0.1 {
//      case let truss as SinglePatchTruss:
//        guard let bytes = dataDict[$0.0] as? [UInt8] else { return nil } // TODO: should throw instead
//        return try truss.createFileData(bytes)
//      case let truss as MultiPatchTruss:
//        guard let byteDict = dataDict[$0.0] as? [SynthPath:[UInt8]] else { return nil }
//        return try truss.fileData(byteDict)
//      default:
//        throw JSError.error(msg: "MultiSysexTruss fileData: unknown truss type in trussMap")
//      }
//
//    }.reduce([], +)
//  }
  
//  func trussMapCountSum() throws -> Int {
//    try anyTrussMap.map { try $0.1.defaultFileDataCount() }.reduce(0, +)
//  }
  
  
//  func sysexibles(data: Data) -> [SynthPath:Sysexible] {
//    var sysexibles = [SynthPath:Sysexible]()
//    SysexData(data: data).forEach { d in
//      for (key, type) in trussMap {
//        guard type.isValid(sysex: d) else { continue }
//        sysexibles[key] = type.init(data: d)
//      }
//    }
//    // UPDATE: leave them nil. for performance e.g., they *should* be nil because some parts are presets.
//    // for any unfilled, init them
////    for (key, type) in trussMap {
////      guard sysexibles[key] == nil else { continue }
////      sysexibles[key] = type.init()
////    }
//    return sysexibles
//  }
}

