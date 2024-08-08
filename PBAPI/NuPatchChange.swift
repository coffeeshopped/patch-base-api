
public enum NuPatchChange : Change {
  public typealias Sysex = AnySysexPatch
  
  case noop
  case replace(AnySysexPatch)
  case nameChange(SynthPath,String)
  case paramsChange(SynthPathInts)
  case push
  
  public static func replace(_ sysex: AnySysexPatch) -> (NuPatchChange, AnySysexPatch?) {
    (.replace(sysex), sysex)
  }
  
  /// So that dictionary mapping methods can be used to construct a paramsChange (e.g. 4.dict { ... })
  public static func paramsChange(_ dict: [SynthPath:Int]) -> NuPatchChange {
    .paramsChange(.init(dict))
  }
  
  public static func params(forPaths paths: [SynthPath], values: [Int]) -> NuPatchChange {
    var dict = SynthPathInts()
    let count = min(paths.count, values.count)
    (0..<count).forEach { dict[paths[$0]] = values[$0] }
    return .paramsChange(dict)
  }
  
  public func filtered(forPrefix prefix: SynthPath?) -> NuPatchChange {
    switch self {
    case .nameChange(let path, let name):
      guard let prefix = prefix else { return self }
      guard path.starts(with: prefix) else { return .noop }
      return .nameChange(path.subpath(from: prefix.count), name)
    case .paramsChange(let params):
      guard let prefix = prefix else { return self }
      return .paramsChange(params.filtered(forPrefix: prefix))
    case let .replace(patch):
      // TODO: what about names? maybe return should be [NuPatchChange]
      guard let prefix = prefix else { return .paramsChange(patch.allValues()) }
      return .paramsChange(patch.allValues().filtered(forPrefix: prefix))
    default:
      return self
    }
  }
  
  public func value(_ path: SynthPath) -> Int? {
    switch self {
    case .paramsChange(let changes):
      return changes[path]
    case .replace(let patch):
      return patch[path]
    case .nameChange, .noop, .push:
      return nil
    }
  }
  
  public func prefixed(_ prefix: SynthPath?) -> NuPatchChange {
    switch self {
    case .nameChange(let path, let name):
      guard let prefix = prefix else { return self }
      return .nameChange(path.prefixed(by: prefix), name)
    case .paramsChange(let params):
      guard let prefix = prefix else { return self }
      return .paramsChange(params.prefixed(prefix))
    case let .replace(patch):
      // TODO: what about names? maybe return should be [NuPatchChange]
      guard let prefix = prefix else { return .paramsChange(patch.allValues()) }
      return .paramsChange(patch.allValues().prefixed(prefix))
    default:
      return self
    }
  }
  
  /// returns a new NuPatchChange representing this instance, but with overwritten values from withChange:
  public func updated(withChange change: NuPatchChange) -> NuPatchChange {
    // for now this only does anything to a paramsChange!
    // ... which should make sense as long as this method is just for throttling
    switch self {
    case .paramsChange(var oldParams):
      switch change {
      case .paramsChange(let newParams):
        newParams.forEach { oldParams[$0.key] = $0.value }
        return .paramsChange(oldParams)
      default:
        return self
      }
    default:
      return self
    }
  }
  
}

