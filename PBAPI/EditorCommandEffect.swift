
public enum EditorCommandEffect {
  
  case single(_ : (EditorCommand) -> EditorCommand)
  case multi(_ : (EditorCommand) -> [EditorCommand])
  
  /// A cross-patch change that listens for multiple parameter changes
  public static func crossPatchParamsChange(_ fn: @escaping (_ path: SynthPath, _ changes: SynthPathInts, _ transmit: Bool) -> [EditorCommand]) -> EditorCommandEffect {
    .multi({ cmd in
      guard case .changePatch(let path, let change, let transmit) = cmd,
            case .paramsChange(let changes) = change else { return [] }
      return fn(path, changes, transmit)
    })
  }
  
  /// When a change in a patch triggers another change in the same patch.
  public static func patchParamChange(_ editorPath: SynthPath, _ paramPath: SynthPath, _ fn: @escaping (_ value: Int, _ transmit: Bool) -> (changes: SynthPathInts, transmit: Bool)) -> EditorCommandEffect {
    .crossPatchParamsChange({ path, changes, transmit in
      guard path == editorPath,
            let v = changes[paramPath] else { return [] }
      let eff = fn(v, transmit)
      return [.changePatch(path: editorPath, .paramsChange(eff.changes), transmit: eff.transmit)]
    })
  }

  /// When a push or replace on a patch resets some editor values. (TX81z op on/off for example)
  public static func patchPushReplaceChange(_ editorPath: SynthPath, _ values: [SynthPath:Int]) -> EditorCommandEffect {
    .multi({ cmd in
      guard case .changePatch(let path, let change, _) = cmd,
            path == editorPath else { return [] }
      switch change {
      case .push, .replace:
        return [.changePatch(path: editorPath, .paramsChange(values), transmit: false)]
      default:
        return []
      }
    })
  }

}
