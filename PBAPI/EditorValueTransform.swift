
public enum EditorValueTransform: Hashable {
  
  case value(_ editorPath: SynthPath, _ paramPath: SynthPath, defaultValue: Int = 0)
  case basicChannel
  case constant(_ value: Int)
  case patch(_ editorPath: SynthPath)
  case extra(_ patchPath: SynthPath, _ paramPath: SynthPath)
  
  public func value(_ editor: AnySynthEditor?) -> Any? {
    switch self {
    case .value(let editorPath, let paramPath, let defaultValue):
      return editor?.parameter(editorPath, paramPath) ?? defaultValue
    case .basicChannel:
      return editor?.basicChannel() ?? 0
    case .constant(let value):
      return value
    case .patch(let editorPath):
      return editor?.patch(forPath: editorPath)
    case .extra(let patchPath, let paramPath):
      return editor?.getExtra(patch: patchPath, param: paramPath)
    }
  }

  public func intValue(_ editor: AnySynthEditor?) throws -> Int {
    guard let v = value(editor) as? Int else {
      throw SysexTrussError.incorrectSysexType(msg: "Bad transform!")
    }
    return v
  }

  // force Int to UInt8 using 2's complement
  public func byteValue(_ editor: AnySynthEditor?) throws -> UInt8 {
    UInt8(bitPattern: Int8(clamping: try intValue(editor)))
  }

}
