
public struct BackupTruss : MultiSysexTruss {
  
  public typealias BodyData = MultiSysexTrussBodyData
  
  public let core: Core

  public let trussMap: [(SynthPath, any SysexTruss)]
  public let trussDict: [SynthPath : any SysexTruss]
  public let trussPaths: [SynthPath]
  
  public init(_ synthName: String, trussMap: [(SynthPath, any SysexTruss)], createFileData: Core.ToMidiFn, parseBodyData: @escaping Core.ParseBodyDataFn, otherValidSizes: [Int]? = nil) {
    self.trussMap = trussMap
    let trussDict = trussMap.dict { [$0.0 : $0.1] }
    self.trussDict = trussDict
    self.trussPaths = trussMap.map { $0.0 }
    
    let fileDataCount = trussMap.map { $0.1.fileDataCount }.reduce(0, +)
    self.core = Core("\(synthName).backup", fileDataCount: fileDataCount, createFileData: createFileData, parseBodyData: parseBodyData, validBundle: .init(sizes: [fileDataCount] + (otherValidSizes ?? [])))
    
  }
  
  public init(_ synthName: String, map: [(SynthPath, any SysexTruss)], pathForData: @escaping BackupTruss.PathForDataFn, createFileData: BackupTruss.Core.ToMidiFn? = nil) {
    let trussDict = map.dict { [$0.0 : $0.1] }
    let createFileData = createFileData ?? .b({ b in
      try Self.defaultCreateFileData(b, trussDict: trussDict)
    })
    self = Self.init(synthName, trussMap: map, createFileData: createFileData, parseBodyData: {
      try Self.defaultParseBodyData($0, trussDict: trussDict, withPathForDataFn: pathForData)
    })
  }

  
  public var namePath: SynthPath? { nil }
  public var defaultName: String { core.defaultName ?? "Backup" }

  public func createEmptyBodyData() throws -> BodyData {
    var bodyData = BodyData()
    try trussMap.forEach {
      bodyData[$0.0] = try $0.1.createInitAnyBodyData()
    }
    return bodyData
  }
  
  public func trussMap(fileData: [UInt8]) -> [(SynthPath, any SysexTruss)]? {
    trussMap
  }
  
  public func trussMap(bodyData: SysexBodyData) -> [(SynthPath, any SysexTruss)]? {
    trussMap
  }
    
  //    try truss.fileData(sysexibles.dictionary(transform: { element in
  //      switch element.value {
  //      case let single as SingleSysexPatch:
  //        return [element.key : single.bytes]
  //      case let multi as MultiSysexPatch:
  //        return [element.key : multi.subpatches]
  //      default:
  //        return [:] // TODO: THROW
  //      }
  //    }))
  
}


public extension BackupTruss {
          
  static func defaultCreateFileData(_ bodyData: BackupTruss.BodyData, trussDict: [SynthPath:any SysexTruss]) throws -> [MidiMessage] {
    try bodyData.compactMap {
      guard let truss = trussDict[$0.key] else { return [] as [MidiMessage] }
      return try truss.createFileData(anyBodyData: $0.value)
    }.reduce([], +)
  }
  
  static func defaultParseBodyData(_ fileData: [UInt8], trussDict: [SynthPath:any SysexTruss], withPathForDataFn pathForData: @escaping BackupTruss.PathForDataFn) throws -> BackupTruss.BodyData {
    var patchData = [SynthPath:Data]()

    // each sysex msg is either a global patch or a patch from one of the banks
    SysexData(data: fileData.data()).forEach { msg in
      guard let path = pathForData(msg.bytes()) else { return }
      if patchData[path] == nil {
        patchData[path] = Data()
      }
      patchData[path]?.append(msg)
    }

    var bodyData = MultiSysexTrussBodyData()
    try patchData.forEach { (path, data) in
      guard let truss = trussDict[path] else { return }
      bodyData[path] = try truss.parseAnyBodyData(fileData: data.bytes())
    }

    // fill in any missing parts of the backup.
    try trussDict.forEach {
      guard bodyData[$0.0] == nil else { return }
      bodyData[$0.0] = try $0.1.createInitAnyBodyData()
    }
    
    return bodyData
  }
  
  func subpatchType(_ path: SynthPath) -> (any SysexTruss)? {
    trussMap.first { $0.0 == path }?.1
  }

}
