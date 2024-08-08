
public enum SysexTrussError : Error {
  case blockNotSet(msg: String)
  case incorrectSysexType(msg: String)
  case fileNotFound(msg: String)
}
