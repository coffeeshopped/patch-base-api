
public struct FullRefTruss : MultiSysexTruss {
  
  /// Given a reference patch, get a map of the different parts of that patch and how they map to the synth's memory. Alternatively, set a map of those values (part -> memory location) for a patch.
//  public struct Iso {
//    public typealias Setter = (_ refPatch: inout AnySysexPatch, [(mem: MemSlot, part: SynthPath)]) throws -> Void
//    public typealias Getter = (_ refPatch: AnySysexPatch) throws -> [(mem: MemSlot, part: SynthPath)]
//    public let set: Setter
//    public let get: Getter
//
//    public init(set: @escaping Setter, get: @escaping Getter) {
//      self.set = set
//      self.get = get
//    }
//  }
  
  
  
  public struct Iso {

    public typealias ValuesFn = (_ mem: MemSlot) throws -> SynthPathInts
    public let values: ValuesFn
    
    // refMem param exists for rare occasions (e.g. JD-Xi) where the location in memory of the refPatch influences the meaning of the parameter values and resulting mapped MemSlot
    // e.g. a JD-Xi program has a "Program" option for each part, and the meaning is "load the part that occupies a specific memory location relative to the memory location of this Program."
    // given `values` return the slot in synth memory being referred to
    public typealias MemSlotFn = (_ values: SynthPathInts, _ refMem: MemSlot) throws -> MemSlot?
    public let memSlot: MemSlotFn
    
    // an optimization; so that only the needed param values can be pulled from a patch (and passed to the MemSlotFn) rather than having to decode every param value!
    public let paramPaths: [SynthPath]
    
    public init(values: @escaping ValuesFn, memSlot: @escaping MemSlotFn, paramPaths: [SynthPath]) {
      self.values = values
      self.memSlot = memSlot
      self.paramPaths = paramPaths
    }
    
    // remap: JD-Xi (anyone else?) where refMem is actually used
    public static func basic(path: SynthPath, location: SynthPath, pathMap: [SynthPath], remap: ((_ refMem: MemSlot, _ toMap: MemSlot) -> MemSlot)? = nil) -> Iso {
      return .init(values: { mem in
        [
          path : pathMap.firstIndex(of: mem.path) ?? 0,
          location : mem.location
        ]
      }, memSlot: { values, refMem in
        let bank = values[path] ?? 0
        let number = values[location] ?? 0
        guard bank < pathMap.count else { return nil }
        let memSlot = MemSlot(pathMap[bank], number)
        return remap?(refMem, memSlot) ?? memSlot
      }, paramPaths: [path, location])

    }

  }
  
  
    
  public typealias BodyData = MultiSysexTrussBodyData
  
  public let core: Core

  // given some sysex data, parse out the body data from the ref (perf) part and return it (for use in constructing the truss map.
  public typealias ParseMapHeadDataFn = ([UInt8]) -> SysexBodyData?
  public let parseMapHeadData: ParseMapHeadDataFn
  // given body data for the ref (perf) part, return a truss map
  public typealias TrussMapFn = (_ headData: SysexBodyData) -> [(SynthPath, any SysexTruss)]
  public let trussMapFn: TrussMapFn
  public let refPath: SynthPath
  public typealias Isos = [SynthPath:Iso]
  public let isos: Isos
  public let sections: [(String, [SynthPath])]
    
//  public let trussDict: [SynthPath : any SysexTruss]
  public let trussPaths: [SynthPath]

  public init(_ displayId: String, trussMap: [(SynthPath, any SysexTruss)], refPath: SynthPath = [.perf], isos: Isos, sections: [(String, [SynthPath])], initFile: String = "", defaultName: String? = nil, createFileData: @escaping Core.ToMidiFn, parseBodyData: @escaping Core.ParseBodyDataFn) {
    self.trussMapFn = { _ in trussMap }
    self.parseMapHeadData = { _ in .single([]) } // always returns something so that trussMap is returned in trussMap(fileData:)
    let trussDict = trussMap.dict { [$0.0 : $0.1] }
//    self.trussDict = trussDict
    self.trussPaths = trussMap.map { $0.0 }
    self.refTruss = trussMap.first(where: { $0.0 == refPath })?.1 as! any PatchTruss
    
    self.refPath = refPath
    self.isos = isos
    self.sections = sections

    let fileDataCount = trussMap.map { $0.1.fileDataCount }.reduce(0, +)
    let maxNameCount = trussDict[refPath]?.maxNameCount ?? 32
    self.core = Core(displayId, initFile: initFile, maxNameCount: maxNameCount, fileDataCount: fileDataCount, defaultName: defaultName, createFileData: createFileData, parseBodyData: parseBodyData, isValidSize: { _ in true }, isValidFileData: { _ in true }, isCompleteFetch: { _ in true })
  }
  
  public init(_ displayId: String, trussMap: [(SynthPath, any SysexTruss)], refPath: SynthPath = [.perf], isos: Isos, sections: [(String, [SynthPath])], initFile: String = "", defaultName: String? = nil, createFileData: @escaping Core.ToMidiFn, pathForData: @escaping PathForDataFn) {
    
    self = Self.init(displayId, trussMap: trussMap, refPath: refPath, isos: isos, sections: sections, initFile: initFile, defaultName: defaultName, createFileData: createFileData, parseBodyData: {
      Self.sysexibles(fileData: $0, trussMap: trussMap, pathForData: pathForData)
    })
    
  }
  
  public init(_ displayId: String, trussMapFn: @escaping TrussMapFn, trussPaths: [SynthPath], parseMapHeadData: @escaping ParseMapHeadDataFn, refPath: SynthPath = [.perf], refTruss: any PatchTruss, isos: Isos, sections: [(String, [SynthPath])], initFile: String = "", defaultName: String? = nil, createFileData: @escaping Core.ToMidiFn, parseBodyData: @escaping Core.ParseBodyDataFn, fileDataCount: Int) {
    self.trussMapFn = trussMapFn
    self.parseMapHeadData = parseMapHeadData
//    self.trussDict = trussDict
    self.trussPaths = trussPaths
    self.refTruss = refTruss
    
    self.refPath = refPath
    self.isos = isos
    self.sections = sections

    let maxNameCount = refTruss.maxNameCount
    self.core = Core(displayId, initFile: initFile, maxNameCount: maxNameCount, fileDataCount: fileDataCount, defaultName: defaultName, createFileData: createFileData, parseBodyData: parseBodyData, isValidSize: { _ in true }, isValidFileData: { _ in true }, isCompleteFetch: { _ in true })
  }
  
  public let refTruss: any PatchTruss
  public var namePath: SynthPath? { refPath }
  public var defaultName: String { core.defaultName ?? "Full Ref" }

  
//  public func defaultFileDataCount() throws -> Int {
//    try trussMapCountSum()
//  }

  public func trussMap(fileData: [UInt8]) -> [(SynthPath, any SysexTruss)]? {
    guard let headData = parseMapHeadData(fileData) else { return nil }
    return trussMapFn(headData)
  }
  
  public func trussMap(bodyData: SysexBodyData) -> [(SynthPath, any SysexTruss)]? {
    guard case .multiSysex(let bodyData) = bodyData,
          let headData = bodyData[refPath] else {
      return nil
    }
    return trussMapFn(headData)
  }
  
  public func createEmptyBodyData() throws -> BodyData {
    return BodyData()
//    var bodyData = BodyData()
//    try trussMap.forEach {
//      bodyData[$0.0] = try $0.1.createInitAnyBodyData()
//    }
//    return bodyData
  }

}

public extension FullRefTruss {
  
  // iterates over truss map, looking for data for that path, then creating fileData from it
  // really only appropriate for a ref that has only one of each patch type
  // if there are multiple (parts), then index/location probably needs to be in the file data
  static func defaultCreateFileData(trussMap: [(SynthPath, any SysexTruss)], bodyData: FullRefTruss.BodyData) throws -> [UInt8] {
    // map over the types to ensure ordering of data
    try trussMap.compactMap {
      guard let bd = bodyData[$0.0] else { return nil }
      return try $0.1.createFileData(anyBodyData: bd)
    }.reduce([], +)
  }
    
  // iterates over truss map, looking for data for that path, then creating fileData from it
  // really only appropriate for a ref that has only one of each patch type
  // if there are multiple (parts), then index/location probably needs to be in the file data
  static func defaultCreateFileData(trussMap: [(SynthPath, any SysexTruss)]) -> FullRefTruss.Core.ToMidiFn {
    { bodyData, e in
      // map over the types to ensure ordering of data
      try trussMap.compactMap {
        guard let bd = bodyData[$0.0] else { return nil }
        return try $0.1.createFileData(anyBodyData: bd)
      }.reduce([], +)
    }
  }

  static func defaultPerfSections(partCount: Int, refPath: SynthPath) -> [(String, [SynthPath])] {
    [
      ("Performance", [refPath]),
      ("Parts", partCount.map { [.part, .i($0)] }),
    ]
  }
  
  // given some file data, a truss map, and a fn to generate synth paths based on data headers,
  // return a dict of body data for various sysex types mapped by internal path
  static func sysexibles(fileData: [UInt8], trussMap: [(SynthPath, any SysexTruss)], pathForData: ([UInt8]) -> SynthPath?) -> MultiSysexTrussBodyData {
    var patchData = [SynthPath:[UInt8]]()
    
    // group the sysex msgs by path
    SysexData(data: Data(fileData)).forEach { msg in
      let bytes = msg.bytes()
      
      // if there's no path for this sysex msg, toss it
      guard let path = pathForData(bytes) else { return }
      
      if patchData[path] == nil {
        patchData[path] = []
      }
      patchData[path]?.append(contentsOf: bytes)
    }

    var p = MultiSysexTrussBodyData()
    patchData.forEach { (path, data) in
      guard let truss = trussMap.first(where: { $0.0 == path })?.1 else { return }
      p[path] = try! truss.parseAnyBodyData(fileData: data)
    }

    // FullPerfs need blank subpatches for preset parts
    // so for any unfilled subpatches, DO NOT init them

    return p
  }
}

