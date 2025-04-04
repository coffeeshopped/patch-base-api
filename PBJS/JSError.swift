import JavaScriptCore

public indirect enum JSError : LocalizedError {
  case error(msg: String)
  case wrap(_ msg: String, _ err: Error)
  case noParseRule(parseRuleSetName: String, value: JSValue, exportOrigin: String?)
  case transformFailure(name: String, match: Match, value: JSValue, err: Error)
  case fnException(fn: JSValue, exception: JSValue, exportOrigin: String?)
    
  public var errorDescription: String? {
    switch self {
    case .error(let msg):
      return msg
    case .wrap(let msg, let err):
      return "\(msg):\n\(err.localizedDescription)"
    case .noParseRule(let parseRuleSetName, let value, let exportOrigin):
      let debugString = value.pbDebug(0, depth: 1)
      let errMsg = "\(parseRuleSetName): no parse rule found for JS Value:\n\(debugString)"
      if let origin = exportOrigin {
        return "in \(origin)\n\(errMsg)"
      }
      else {
        return errMsg
      }
    case .transformFailure(let name, let match, let value, let err):
      let errMsg = "Parse rule failed: \(name):\nPattern: \(match.string())\nValue:\n\(value.pbDebug())"
      if let origin = exportOrigin {
        return "in \(origin)\n\(err.localizedDescription)\n\(errMsg)"
      }
      else {
        return "\(err.localizedDescription)\n\(errMsg)"
      }
    case .fnException(let fn, let exception, let exportOrigin):
      let excStr = exception.toString() ?? "Unknown exception."
      return "JS Exception thrown when calling function: \(excStr)\n\(fn.pbDebug())"
    }
  }
  
  public var basicDescription: String {
    switch self {
    case .error(let msg):
      return msg
    case .wrap(let msg, let err):
      return msg
//      return "\(msg):\n\(err.localizedDescription)"
    case .noParseRule(let parseRuleSetName, let value, _):
      let debugString = value.pbDebug(0, depth: 1)
      return "\(parseRuleSetName): no parse rule found for JS Value:\n\(debugString)"
    case .transformFailure(let name, let match, let value, let err):
      return "\(name): parse rule failed:\nPattern: \(match.string())\nValue:\n\(value.pbDebug())"
    case .fnException(let fn, let exception, let exportOrigin):
      let excStr = exception.toString() ?? "Unknown exception."
      return "JS Exception thrown when calling function: \(excStr)\n\(fn.pbDebug())"
    }
  }
  
  public var innermostError: JSError {
    switch self {
    case .error, .wrap, .noParseRule, .fnException:
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
    case .error:
      return nil
    case .wrap(_, let error):
      return (error as? Self)?.innermostOrigin
    case .transformFailure(_, _, let value, let err):
      return (err as? Self)?.innermostOrigin ?? value.exportOrigin()
    case .fnException(_, _, let exportOrigin):
      return exportOrigin
    case .noParseRule(_, let value, let exportOrigin):
      return exportOrigin ?? value.exportOrigin()
    }
  }
  
  public var exportOrigin: String? {
    switch self {
    case .error, .wrap:
      return nil
    case .noParseRule(_, let value, let exportOrigin):
      return exportOrigin ?? value.exportOrigin()
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
    case .fnException(_, _, let exportOrigin):
      return exportOrigin
    }
  }
  
  public func invert() -> [any Error] {
    switch self {
    case .error, .noParseRule, .fnException:
      return [self]
    case .wrap(_, let err), .transformFailure(_, _, _, let err):
      if let err = err as? JSError {
        return err.invert() + [self]
      }
      else {
        return [err, self]
      }
    }
  }
  
  public var value: JSValue? {
    switch self {
    case .error, .wrap:
      return nil
    case .fnException(let fn, _, _):
      return fn
    case .noParseRule(_, let value, _):
      return value
    case .transformFailure(_, _, let value, _):
      return value
    }
  }
}
