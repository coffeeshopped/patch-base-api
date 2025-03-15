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
//      if let origin = exportOrigin {
//        return "in \(origin)\n\(errMsg)"
//      }
//      else {
        return errMsg
//      }
    case .transformFailure(let name, let match, let value, let err):
      let errMsg = "Parse rule failed: \(name):\nPattern: \(match.string())\nValue:\n\(value.pbDebug())"
      if let origin = exportOrigin {
        return "in \(origin)\n\(err.localizedDescription)\n\(errMsg)"
      }
      else {
        return "\(err.localizedDescription)\n\(errMsg)"
      }
    }
  }
  
  public var basicDescription: String {
    switch self {
    case .error(let msg):
      return msg
    case .wrap(let msg, let err):
      return "\(msg):\n\(err.localizedDescription)"
    case .noParseRule(let parseRuleSetName, let value):
      let debugString = value.pbDebug(0, depth: 1)
      return "\(parseRuleSetName): no parse rule found for JS Value:\n\(debugString)"
    case .transformFailure(let name, let match, let value, let err):
      return "Parse rule failed: \(name):\nPattern: \(match.string())\nValue:\n\(value.pbDebug())"
    }
  }
  
  public var innermostError: JSError {
    switch self {
    case .error, .wrap, .noParseRule:
      return self
    case .transformFailure(_, _, let value, let err):
      if let err = err as? JSError {
        return err.innermostError
      }
      else {
        return self
      }
    }
  }
  
  public var innermostOrigin: String? {
    switch self {
    case .error, .wrap, .noParseRule:
      return nil
    case .transformFailure(_, _, let value, let err):
      if let err = err as? JSError {
        return err.innermostOrigin ?? value.exportOrigin()
      }
      else {
        return value.exportOrigin()
      }
    }
  }
  
  public var exportOrigin: String? {
    switch self {
    case .error, .wrap:
      return nil
    case .noParseRule(_, let value):
      return value.exportOrigin()
    case .transformFailure(_, _, let value, let err):
      if let o = value.exportOrigin() {
        return o
      }
      else if let err = err as? JSError {
        return err.exportOrigin
      }
      else {
        return nil
      }
    }
  }
}
