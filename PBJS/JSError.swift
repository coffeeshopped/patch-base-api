import JavaScriptCore

public indirect enum JSError : LocalizedError {
  case error(msg: String)
  case wrap(_ msg: String, _ err: Error)
  case noParseRule(parseRuleSetName: String, value: JSValue)
  case transformFailure(name: String, match: Match, value: JSValue, err: Error)
    
  public var errorDescription: String? {
    switch self {
    case .error(let msg):
      return msg
    case .wrap(let msg, let err):
      return "\(msg):\n\(err.localizedDescription)"
    case .noParseRule(let parseRuleSetName, let value):
      let debugString = value.pbDebug(0, depth: 1)
      let errMsg = "\(parseRuleSetName): no parse rule found for JS Value:\n\(debugString)"
      if let origin = value.exportOrigin() {
        return "in \(origin)\n\(errMsg)"
      }
      else {
        return errMsg
      }
    case .transformFailure(let name, let match, let value, let err):
      let errMsg = "Parse rule failed: \(name): \(match.string()) --\n\(value.pbDebug())"
      if let origin = value.exportOrigin() {
        return "\(err.localizedDescription)\nin \(origin)\n\(errMsg)"
      }
      else {
        return "\(err.localizedDescription)\n\(errMsg)"
      }
    }
  }
}
