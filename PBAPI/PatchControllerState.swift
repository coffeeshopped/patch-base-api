
public struct PatchControllerState {
  public var event: PatchControllerEvent
  public var index: Int = 0
  public var prefix: SynthPath?
  public var params: SynthPathParam
  public var values: SynthPathInts
  public var names: [SynthPath:String]
  public var controls = [SynthPath:Int]() // latest values of our controls (needed by CChange)
  
  public init(event: PatchControllerEvent, prefix: SynthPath? = nil, params: SynthPathParam, values: SynthPathInts, names: [SynthPath : String]) {
    self.event = event
    self.prefix = prefix
    self.params = params
    self.values = values
    self.names = names
  }
  
  public func changedValuePaths() -> [SynthPath] {
    switch event {
    case .initialize, .nameChange, .paramsChange:
      return []
    case .patchReplace, .prefixChange:
      return Array(values.keys)
    case .valuesChange(let paths):
      return paths
    }
  }
  
  // given a full path, filter it based on the current prefix
  func localPath(fullPath: SynthPath) -> SynthPath {
    guard let prefix = prefix else { return fullPath }
    return fullPath.starts(with: prefix) ? Array(fullPath.suffix(from: prefix.count)) : []
  }
  
  public func prefixTransform(_ path: SynthPath) -> SynthPath {
    prefix == nil ? path : prefix! + path
  }

  public func prefixedValue(_ path: SynthPath) -> Int? {
    values[prefixTransform(path)]
  }
    
  func valuesForFullPaths(_ fullPaths: [SynthPath]) -> SynthPathInts {
    .init(fullPaths.compactDict {
      guard let v = values[$0] else { return nil }
      return [$0 : v]
    })
  }

  public func values(paths: [SynthPath]) -> SynthPathInts {
    let fullPaths = paths.map { prefixTransform($0) }
    return valuesForFullPaths(fullPaths).filtered(forPrefix: prefix)
  }

  
  /// get updatedValue without regard to this controller's prefix
  public func updatedValueForFullPath(_ fullPath: SynthPath) -> Int? {
    switch event {
    case .nameChange, .paramsChange:
      return nil
    case .prefixChange, .patchReplace, .initialize:
      return values[fullPath]
    case .valuesChange(let paths):
      guard paths.contains(fullPath) else { return nil }
      return values[fullPath]
    }
  }
  
  func updatedValuesForFullPaths(fullPaths: [SynthPath]) -> SynthPathInts? {
    let anyUpdated: Bool = fullPaths.reduce(false, {
      $0 || (updatedValueForFullPath($1) != nil)
    })
    
    // check that at least one path was updated
    guard anyUpdated else { return nil }
    
    return valuesForFullPaths(fullPaths)
    // check that we had values for all the paths
    // UPDATE: Why? I don't think that's needed
//    guard values.keys.count == fullPaths.count else { return nil }
  }
  
  /// Default update function for a control mapped to a path
  public func updatedValue(path: SynthPath) -> Int? {
    updatedValueForFullPath(prefixTransform(path))
  }

  /// Checks to see if any of the paths have been updated. If so, returns values for all. Otherwise, nil.
  public func updatedValues(paths: [SynthPath]) -> SynthPathInts? {
    let fullPaths = paths.map { prefixTransform($0) }
    return updatedValuesForFullPaths(fullPaths: fullPaths)?.filtered(forPrefix: prefix)
  }

}
