
import PBAPI
import JavaScriptCore
import OrderedCollections

public struct JsParseRule<Output:Any> {
    
  public let match: Match
  let xform: (JSValue) throws -> Output
  public let name: String
  
  init(_ match: Match, _ xform: @escaping (JSValue) throws -> Output, _ name: String) {
    self.match = match
    self.xform = xform
    self.name = name
  }

  static func a(_ s: String, _ arr: [any JsParsable.Type], optional: [any JsParsable.Type] = [], _ xform: @escaping (JSValue) throws -> Output, _ name: String? = nil) -> Self {
    .init(.a(s, arr, optional: optional), xform, name ?? s)
  }

  static func b(_ b: Int, _ arr: [any JsParsable.Type], optional: [any JsParsable.Type] = [], _ xform: @escaping (JSValue) throws -> Output, _ name: String? = nil) -> Self {
    .init(.b(b, arr, optional: optional), xform, name ?? "\(b)")
  }

  static func arr(_ arr: [any JsParsable.Type], optional: [any JsParsable.Type] = [], _ xform: @escaping (JSValue) throws -> Output, _ name: String) -> Self {
    .init(.arr(arr, optional: optional), xform, name)
  }

  static func s(_ match: String, _ xform: @escaping (JSValue) throws -> Output, _ name: String? = nil) -> Self {
    .init(.s(match), xform, name ?? match)
  }

  static func s(_ match: String, _ out: Output, _ name: String? = nil) -> Self {
    .init(.s(match), { _ in out }, name ?? match)
  }

  static func t(_ match: any JsParsable.Type, _ xform: @escaping (JSValue) throws -> Output, _ name: String? = nil) -> Self {
    .init(.t(match), xform, name ?? match.jsName())
  }

  static func d(_ match: OrderedDictionary<String,any JsParsable.Type>, _ xform: @escaping (JSValue) throws -> Output, _ name: String) -> Self {
    .init(.d(match), xform, name)
  }

  func matches(_ value: JSValue) -> Bool {
    match.matches(value)
  }
  
  func transform(_ x: JSValue) throws -> Output {
    // first, check for match
    do {
      return try xform(x)
    }
    catch {
      throw JSError.transformFailure(name: (Output.self as? any JsParsable.Type)?.jsName() ?? String(reflecting: Output.self), match: match, value: x, err: error)
    }
  }

}


public enum Match {
  case d(OrderedDictionary<String,any JsParsable.Type>)
  case s(String)
  case a(String, [any JsParsable.Type], optional: [any JsParsable.Type])
  case b(Int, [any JsParsable.Type], optional: [any JsParsable.Type])
  case t(any JsParsable.Type)
  case arr([any JsParsable.Type], optional: [any JsParsable.Type])
  
  // check whether a given JSValue matches this pattern
  func matches(_ x: JSValue) -> Bool {
    switch self {
    case .d(let dict):
      for (k, v) in dict {
        guard k.hasSuffix("?") || v.matches(x.forProperty(k)) else { return false }
      }
      return true
    case .s(let s):
      return x.isString && x.toString() == s
    case .a(let key, let args, let opts):
      guard x.isArray,
            x.arrCount() >= args.count + 1,
            x.atIndex(0).isString,
            x.atIndex(0).toString() == key else { return false }
      return args.enumerated().reduce(true) { partialResult, pair in
        guard partialResult else { return false }
        return pair.element.matches(x.atIndex(pair.offset + 1))
      }
    case .b(let key, let args, let opts):
      guard x.isArray,
            x.arrCount() >= args.count + 1,
            x.atIndex(0).isNumber,
            x.atIndex(0).toInt32() == key else { return false }
      return args.enumerated().reduce(true) { partialResult, pair in
        guard partialResult else { return false }
        return pair.element.matches(x.atIndex(pair.offset + 1))
      }
    case .t(let t):
      if let t = t as? any JsDirectParsable.Type {
        return t.matches(x)
      }
      return t.matches.contains(where: { $0.matches(x) })

    case .arr(let args, let opts):
      // special case: a rule with a single-element args, and opts is nil
      // I *think* this match is only used for "array" rules for types,
      // i.e. for matching an array of 0 or more elements of a single type
      // so, allow an ampty array in this case
      // that will match to the defaultArrayRule, which will return a parsed empty array.
      if args.count == 1 && opts.count == 0 && x.isArray && x.arrCount() == 0 {
        return true
      }
      
      
      guard x.isArray,
            x.arrCount() >= args.count else { return false }
      return args.enumerated().reduce(true) { partialResult, pair in
        guard partialResult else { return false }
        return pair.element.matches(x.atIndex(pair.offset))
      }
    }
  }

  public func string(links: Bool = false) -> String {
    switch self {
    case .d(let dict):
      return "{\n\(dict.map { "  \($0.key): \(Self.jsName($0.value, links: links))" }.joined(separator: ",\n"))\n}"
    case .s(let s):
      return "\"\(s)\""
    case .a(let key, let args, let opts):
      let argString = args.count == 0 ? "" : ", " + args.map { Self.jsName($0, links: links) }.joined(separator: ", ")
      let optString = opts.count == 0 ? "" : ", " + opts.map { "\(Self.jsName($0, links: links))?" }.joined(separator: ", ")
      return "[\"\(key)\"\(argString)\(optString)]"
    case .b(let key, let args, let opts):
      let argString = args.count == 0 ? "" : ", " + args.map { Self.jsName($0, links: links) }.joined(separator: ", ")
      let optString = opts.count == 0 ? "" : ", " + opts.map { "\(Self.jsName($0, links: links))?" }.joined(separator: ", ")
      return "[\(key)\(argString)\(optString)]"
    case .t(let t):
      return "\(t)"
    case .arr(let args, let opts):
      let argString = args.map { Self.jsName($0, links: links) }.joined(separator: ", ")
      let optString = opts.map { "\(Self.jsName($0, links: links))?" }.joined(separator: ", ")
      let joinString = args.count > 0 && opts.count > 0 ? ", " : ""
      return "[\(argString)\(joinString)\(optString)]"
    }
  }
  
  private static func jsName(_ t: any JsParsable.Type, links: Bool) -> String {
    if links {
      let n = t.jsName()
      if n.hasPrefix("[") {
        let noBrackets = n.replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "")
        if noBrackets.contains(":") {
          return "[::\(noBrackets.split(separator: ":").joined(separator: ":::::"))::]"
        }
        else {
          return "[::\(noBrackets)::]"
        }
      }
      else {
        return "::\(t.jsName())::"
      }
    }
    else {
      return t.jsName()
    }
  }

}
