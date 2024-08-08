
public enum ModuleCommandEffect {
  
  case editor(_ : (EditorCommand) -> [ModuleCommand])
  
  /// A cross-patch change that listens for multiple parameter changes
  public static func crossPatchParamsChange(_ fn: @escaping (_ path: SynthPath, _ changes: SynthPathInts, _ transmit: Bool) -> [ModuleCommand]) -> Self {
    .editor({ cmd in
      guard case .changePatch(let path, let change, let transmit) = cmd,
            case .paramsChange(let changes) = change else { return [] }
      return fn(path, changes, transmit)
    })
  }
  
//  /// When a change in a patch triggers another change in the same patch.
//  public static func patchParamChange(_ editorPath: SynthPath, _ paramPath: SynthPath, _ fn: @escaping (_ value: Int, _ transmit: Bool) -> (changes: SynthPathInts, transmit: Bool)) -> Self {
//    .crossPatchParamsChange({ path, changes, transmit in
//      guard path == editorPath,
//            let v = changes[paramPath] else { return [] }
//      let eff = fn(v, transmit)
//      return [.changePatch(path: editorPath, .paramsChange(eff.changes), transmit: eff.transmit)]
//    })
//  }
//
  /// When a param change (either individual param change, or a replace)
  public static func patchParamChange(_ editorPath: SynthPath, _ paramPath: SynthPath, _ fn: @escaping (Int) -> [ModuleCommand]) -> Self {
    .editor({ cmd in
      guard case .changePatch(let path, let change, _) = cmd,
            path == editorPath else { return [] }
      switch change {
      case .paramsChange(let values):
        guard let v = values[paramPath] else { return [] }
        return fn(v)
      case .replace(let patch):
        guard let v = patch[paramPath] else { return [] }
        return fn(v)
      case .nameChange, .noop, .push:
        return []
      }
    })
  }

}
