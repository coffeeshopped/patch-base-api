
public indirect enum JSError : Error {
  case error(msg: String)
  case wrap(_ msg: String, _ err: Error)
  
  public func display() -> String {
    switch self {
    case .error(let msg):
      return msg
    case .wrap(let msg, let err):
      if let err = err as? JSError {
        return "\(msg):\n\(err.display())"
      }
      else {
        return "\(msg):\n\(err.localizedDescription)"
      }
    }
  }
}
