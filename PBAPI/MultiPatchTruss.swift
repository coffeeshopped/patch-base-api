
public struct MultiPatchTruss : PatchTruss {
  
  public typealias BodyData = [SynthPath:[UInt8]]
  public func sysexBodyData(_ data: BodyData) -> SysexBodyData { .multi(data) }

  public let core: Core

  public let trussMap: [(SynthPath, SinglePatchTruss)]
  /// path to subpatch that holds name data
  public let namePath: SynthPath?

  /// created from trussMap
  public let trussPaths: [SynthPath]
  public let trussDict: [SynthPath:SinglePatchTruss]

  public init(_ displayId: String, trussMap: [(SynthPath, SinglePatchTruss)], namePath: SynthPath? = nil, initFile: String = "", fileDataCount: Int? = nil, defaultName: String? = nil, createFileData: Core.ToMidiFn? = nil, parseBodyData: Core.ParseBodyDataFn? = nil, validBundle bundle: Core.ValidBundle? = nil) {
    
    self = Self.init(displayId, trussMap: trussMap, namePath: namePath, initFile: initFile, fileDataCount: fileDataCount, defaultName: defaultName, createFileData: createFileData, parseBodyData: parseBodyData, isValidSize: bundle?.validSize, isValidFileData: bundle?.validData, isCompleteFetch: bundle?.completeFetch)
  }
  
  public init(_ displayId: String, trussMap: [(SynthPath, SinglePatchTruss)], namePath: SynthPath? = nil, initFile: String = "", fileDataCount: Int? = nil, defaultName: String? = nil, createFileData: Core.ToMidiFn? = nil, parseBodyData: Core.ParseBodyDataFn? = nil, isValidSize: Core.ValidSizeFn? = nil, isValidFileData: Core.ValidDataFn? = nil, isCompleteFetch: Core.ValidDataFn? = nil) {
    self.trussMap = trussMap
    self.trussPaths = trussMap.map { $0.0 }
    self.trussDict = trussMap.dict { [$0.0 : $0.1] }

    self.namePath = namePath

    let maxNameCount = trussMap.first { $0.0 == namePath }?.1.maxNameCount ?? 32
    let fileDataCount = fileDataCount ?? Self.fileDataCount(trusses: trussMap.map { $0.1 })
    
    let createFileData = createFileData ?? { b, e in
      try Self.defaultCreateFileData(bodyData: b, trussMap: trussMap)
    }
    let parseBodyData = parseBodyData ?? {
      try Self.defaultParseBodyData(fileData: $0, trussMap: trussMap)
    }
    
    self.core = Core(displayId, initFile: initFile, maxNameCount: maxNameCount, fileDataCount: fileDataCount, defaultName: defaultName, createFileData: createFileData, parseBodyData: parseBodyData, isValidSize: isValidSize, isValidFileData: isValidFileData, isCompleteFetch: isCompleteFetch)
  }
  
  public init(_ displayId: String, trussMap: [(SynthPath, SinglePatchTruss)], namePath: SynthPath? = nil, initFile: String = "", fileDataCount: Int? = nil, defaultName: String? = nil, createFileData: Core.ToMidiFn? = nil, parseBodyData: Core.ParseBodyDataFn? = nil, validSizes: [Int], includeFileDataCount: Bool) {
    
    let fileDataCount = fileDataCount ?? Self.fileDataCount(trusses: trussMap.map { $0.1 })
    let finalValidSizes = (includeFileDataCount ? [fileDataCount] : []) + validSizes
    let validBundle = Core.validBundle(counts: finalValidSizes)
    
    self = Self.init(displayId, trussMap: trussMap, namePath: namePath, initFile: initFile, fileDataCount: fileDataCount, defaultName: defaultName, createFileData: createFileData, parseBodyData: parseBodyData, validBundle: validBundle)
  }
  
  private static func fileDataCount(trusses: [SinglePatchTruss]) -> Int {
    trusses.map { $0.fileDataCount }.reduce(0, +)
  }
  
  /// Generate a ValidBundle using the default fileDataCount method plus any other valid sizes.
  public static func fileDataCountBundle(trusses: [SinglePatchTruss], validSizes: [Int], includeFileDataCount: Bool) -> Core.ValidBundle {
    let finalValidSizes = (includeFileDataCount ? [fileDataCount(trusses: trusses)] : []) + validSizes
    return Core.validBundle(counts: finalValidSizes)
  }

  public static func defaultParseBodyData(fileData: [UInt8], trussMap: [(SynthPath, SinglePatchTruss)]) throws -> MultiPatchTruss.BodyData {
    var bodyData = BodyData()
    
    try SysexData(data: Data(fileData)).forEach { d in
      for (path, truss) in trussMap {
        let b = d.bytes()
        guard truss.isValidFileData(b) else { continue }
        bodyData[path] = try truss.parseBodyData(b)
      }
    }
    
    // for any unfilled bodyData, init
    for (path, truss) in trussMap {
      guard bodyData[path] == nil else { continue }
      bodyData[path] = try truss.createInitBodyData()
    }
    
    return bodyData
  }
  
  public static func defaultCreateFileData(bodyData: MultiPatchTruss.BodyData, trussMap: [(SynthPath, SinglePatchTruss)]) throws -> [UInt8] {
    // map over the types to ensure ordering of data
    return try trussMap.compactMap {
      guard let bytes = bodyData[$0.0] else { return nil }
      return try $0.1.createFileData(bytes)
    }.reduce([], +)
  }
      
  func subpatchType(_ path: SynthPath) -> SinglePatchTruss? {
    trussMap.first { $0.0 == path }?.1
  }
  
  public func subpaths(_ path: SynthPath) -> [SynthPath]? {
    for (subpatchPath, _) in trussMap {
      guard path.starts(with: subpatchPath) else { continue }
      return [subpatchPath, path.subpath(from: subpatchPath.count)]
    }
    return nil
  }

  public func parm(_ path: SynthPath) -> Parm? {
    guard let subpaths = subpaths(path),
          subpaths.count >= 2 else { return nil }
    return subpatchType(subpaths[0])?.parm(subpaths[1])
  }
  
  public func paramKeys() -> [SynthPath] {
    var keys = [SynthPath]()
    for (subpatchPath, patchType) in trussMap {
      keys.append(contentsOf: patchType.paramKeys().map { $0.prefixed(by: subpatchPath) })
    }
    return keys
  }
    
  public func createEmptyBodyData() throws -> BodyData {
    var bodyData = BodyData()
    try trussMap.forEach {
      bodyData[$0.0] = try $0.1.createInitBodyData()
    }
    return bodyData
  }
  
  public func getValue(_ bodyData: BodyData, path: SynthPath) -> Int? {
    for (subpath, patchTruss) in trussMap {
      guard path.starts(with: subpath) else { continue }
      
      let paramPath = path.subpath(from: subpath.count)
      guard let data = bodyData[subpath] else { return nil }
      return patchTruss.getValue(data, path: paramPath)
    }
    return nil
  }
  
  public func setValue(_ bodyData: inout BodyData, path: SynthPath, _ value: Int) {
    trussMap.forEach { (subpath, patchTruss) in
      guard path.starts(with: subpath) else { return }
      
      let paramPath = path.subpath(from: subpath.count)
      guard var data = bodyData[subpath] else { return }
      patchTruss.setValue(&data, path: paramPath, value)
      bodyData[subpath] = data
    }
  }
  
  public func allValues(_ bodyData: BodyData) -> SynthPathInts {
    var v = SynthPathInts()
    trussMap.forEach {
      guard let data = bodyData[$0.0] else { return }
      v.merge(new: $0.1.allValues(data).prefixed($0.0))
    }
    return v
  }


  public func getName(_ bodyData: [SynthPath : [UInt8]]) -> String? {
    guard let namePath = namePath,
          let data = bodyData[namePath] else { return nil }
    return trussDict[namePath]?.getName(data)
  }
  
  public func setName(_ bodyData: inout [SynthPath : [UInt8]], _ value: String) {
    guard let namePath = namePath,
          var data = bodyData[namePath] else { return }
    trussDict[namePath]?.setName(&data, value)
    bodyData[namePath] = data
  }
  
  public func getName(_ bodyData: BodyData, forPath path: SynthPath) -> String? {
    guard path.count > 0 else { return getName(bodyData) }
    guard let data = bodyData[path] else { return nil }
    return trussDict[path]?.getName(data)
  }
  
  public func setName(_ bodyData: inout BodyData, forPath path: SynthPath, _ name: String) {
    guard path.count > 0 else { return setName(&bodyData, name) }
    guard var data = bodyData[path] else { return }
    trussDict[path]?.setName(&data, name)
    bodyData[path] = data
  }

  public func allNames(_ bodyData: BodyData) -> [SynthPath:String] {
    var names: [SynthPath:String] = [:]
    if let name = getName(bodyData) {
      names[[]] = name
    }
    trussPaths.forEach { path in
      guard let t = trussDict[path],
            let data = bodyData[path],
            let name = t.getName(data) else { return }
      names[path] = name
    }
    return names
  }

  public func randomize() -> SynthPathInts {
    var v = SynthPathInts()
    trussMap.forEach {
      v.merge(new: $0.1.randomize().prefixed($0.0))
    }
    return v
  }


}
