
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

  // force Int to UInt8 using 2's complement
  func byteValue(_ transform: EditorValueTransform?) throws -> UInt8 {
    UInt8(bitPattern: Int8(try intValue(transform)))
  }

}
