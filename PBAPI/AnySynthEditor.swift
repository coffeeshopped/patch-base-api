
public protocol AnySynthEditor {

  func map(fromPath path: SynthPath) -> SynthPath?
  func patch(forPath path: SynthPath) -> AnySysexPatch?
  func value(_ transform: EditorValueTransform?) -> Any?

}

public extension AnySynthEditor {
  
  func intValue(_ transform: EditorValueTransform?) throws -> Int {
    guard let v = value(transform) as? Int else {
      throw SysexTrussError.incorrectSysexType(msg: "Bad transform!")
    }
    return v
  }

  func byteValue(_ transform: EditorValueTransform?) throws -> UInt8 {
    guard let v = value(transform) as? UInt8 else {
      throw SysexTrussError.incorrectSysexType(msg: "Bad transform!")
    }
    return v
  }

}
