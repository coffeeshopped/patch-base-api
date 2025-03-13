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
      let origin: String = (try? value.x("EXPORT_ORIGIN")) ?? "?"
      return "in \(origin)\n\(parseRuleSetName): no parse rule found for JS Value:\n\(debugString)"
    case .transformFailure(let name, let match, let value, let err):
      let origin: String = (try? value.x("EXPORT_ORIGIN")) ?? "?"
      return "\(err.localizedDescription)\nin \(origin)\nContext: \(name): \(match.string()) --\n\(value.pbDebug())"
    }
  }
}
