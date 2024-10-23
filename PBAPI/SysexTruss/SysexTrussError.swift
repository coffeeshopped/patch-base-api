
public enum SysexTrussError : Error {
  case blockNotSet(msg: String)
  case incorrectSysexType(msg: String)
  case fileNotFound(msg: String)
  
  public func display() -> String {
    switch self {
    case .blockNotSet(let msg):
      return "Block not set: \(msg)"
    case .incorrectSysexType(let msg):
      return "Incorrect Sysex Type: \(msg)"
    case .fileNotFound(let msg):
      return "File not found: \(msg)"
    }
  }
}
