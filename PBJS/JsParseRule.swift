
import PBAPI
import JavaScriptCore

struct JsParseRule<Output:Any> {
  let match: Any
  let xform: (JSValue) throws -> Output
  
  init(_ match: Any, _ xform: @escaping (JSValue) throws -> Output) {
    self.match = match
    self.xform = xform
  }
  
  static func a(_ match: [String], _ xform: @escaping (JSValue) throws -> Output) -> Self {
    .init(match, xform)
  }

  static func a(_ match: [Int], _ xform: @escaping (JSValue) throws -> Output) -> Self {
    .init(match, xform)
  }

  static func d(_ match: [String:String], _ xform: @escaping (JSValue) throws -> Output) -> Self {
    .init(match, xform)
  }

  static func s(_ match: String, _ xform: @escaping (JSValue) throws -> Output) -> Self {
    .init(match, xform)
  }

  static func s(_ match: String, _ output: Output) -> Self {
    .init(match, { _ in output })
  }
  
  func matches(_ value: JSValue) -> Bool {
    try! Match.from(any: match).matches(value)
  }
  
  func transform(_ x: JSValue) throws -> Output {
    // first, check for match
    do {
      return try xform(x)
    }
    catch {
      throw JSError.transformFailure(name: String(reflecting: Output.self), match: try! Match.from(any: match), value: x, err: error)
    }
  }


}

public enum Match {
  case a([MatchItem])
  case obj([String:MatchItem])
  case single(MatchItem)
  
  // check whether a given JSValue matches this pattern
  func matches(_ x: JSValue) -> Bool {
    switch self {
    case .a(let arr):
      guard x.isArray else { return false }
      for i in 0..<arr.count {
        guard arr[i].matches(x.atIndex(i)) else { return false }
      }
      return true
    case .obj(let dict):
      for (k, v) in dict {
        guard v.matches(x.forProperty(k)) else { return false }
      }
      return true
    case .single(let item):
      return item.matches(x)
    }
  }
  
  static func from(_ strArr: [String]) throws -> Self {
    try .a(strArr.map { try MatchItem.from($0) })
  }

  static func from(_ dict: [String:String]) throws -> Self {
    try .obj(dict.dict { [$0 : try MatchItem.from($1)] })
  }

  static func from(_ str: String) throws -> Self {
    .single(try MatchItem.from(str))
  }
  
  static func from(_ intArr: [Int]) throws -> Self {
    .a(intArr.map { .ci($0) })
  }

  static func from(any: Any) throws -> Self {
    switch any {
    case let arr as [String]:
      return try from(arr)
    case let dict as [String:String]:
      return try from(dict)
    case let str as String:
      return try from(str)
    case let arr as [Int]:
      return try from(arr)
    default:
      throw JSError.error(msg: "Unrecognized Match specifier: \(any)")
    }

  }


  func string() -> String {
    switch self {
    case .a(let items): return "[\(items.map { $0.string() }.joined(separator: ", "))]"
    case .single(let item): return item.string()
    case .obj(let dict): return "{ \(dict.map { "\($0.key): \($0.value.string())" }.joined(separator: ", ")) }"
    }
  }
}

public indirect enum MatchItem : Equatable, Hashable {
  case c(String)
  case ci(Int)
  case arr
  case dict
  case str
  case num
  case opt(MatchItem)
  case path
  case fn
  case bool
  case any
  
  func matches(_ x: JSValue) -> Bool {
    switch self {
    case .c(let str):
      return x.isString && x.toString() == str
    case .ci(let int):
      return x.isNumber && x.toInt32() == Int32(int)
    case .arr:
      return x.isArray
    case .dict:
      return x.isObject
    case .str:
      return x.isString
    case .opt(let item):
      return x.isUndefined || x.isNull || item.matches(x)
    case .path:
      return x.isString || x.isNumber || x.isArray
    case .fn:
      return x.isFn
    case .num:
      return x.isNumber
    case .bool:
      return x.isBoolean
    case .any:
      return !x.isUndefined && !x.isNull
    }
  }
  
  static let keys: Dictionary<Character,MatchItem> = [
    "a" : .arr,
    "d" : .dict,
    "s" : .str,
    "p" : .path,
    "f" : .fn,
    "n" : .num,
    "b" : .bool,
    "x" : .any,
  ]
  
  static let prettyKeys: Dictionary<MatchItem,String> = [
    .arr : "Array",
    .dict : "Object",
    .str : "String",
    .path : "Path",
    .fn : "Function",
    .num : "Number",
    .bool : "Boolean",
    .any : "Any",
  ]
  
  static func from(_ str: String) throws -> Self {
    guard str.starts(with: ".") else { return .c(str) }
    let chars = Array(str)
    guard chars.count > 1 else { throw JSError.error(msg: "Invalid MatchItem specifier: .")}
    guard let x = keys[chars[1]] else { throw JSError.error(msg: "Unknown MatchItem specifier: \(str)") }
    return chars.count > 2 && chars[2] == "?" ? .opt(x) : x
  }

  func string() -> String {
    switch self {
    case .c(let str): return "\"\(str)\""
    case .opt(let item): return "\(item.string())?"
    default:
      return Self.prettyKeys[self] ?? "_"
    }
  }

  
}


protocol JsParsable {
  
  static var jsRules: [JsParseRule<Self>] { get }
  static var jsArrayRules: [JsParseRule<[Self]>] { get }
  
}

//extension JsParsable {
//  static func x(_ v: JSValue) throws -> Self {
//    try v.xform(jsParsers)
//  }
//}

extension JsParsable {
  
  static var jsArrayRules: [JsParseRule<[Self]>] { [] }
  
  static func defaultArrayRule() -> JsParseRule<[Self]> {
    .s(".a", {
      // ok, so what are we doing here?
      guard $0.arrCount() > 0 else { return [] }
      // go through each item
      return try $0.flatMap {
        do {
          // if the item parses as a single element, return it (as an array for flattening)
          let x: Self = try $0.x()
          return [x]
        }
        catch {
          // if that item doesn't parse, try parsing the item as an array of elements
          let e = error
          do {
            // if it parses as an array, return that array
            let arr: [Self] = try $0.xform(jsArrayRules + [defaultArrayRule()])
            return arr
          }
          catch {
            // but if it doesn't parse, throw the error from parsing THE FIRST ELEMENT,
            // rather than the error from parsing an array
            // WHY?
            // because that's a "deeper" error and more likely to yield useful debug info.
            throw e
          }
        }
      }
    })
  }
  
}

extension Array: JsParsable where Element: JsParsable {
  static var jsRules: [JsParseRule<Self>] {
    Element.jsArrayRules + [Element.defaultArrayRule()]
  }
}

extension Dictionary: JsParsable where Key: JsParsable, Value: JsParsable {
  static var jsRules: [JsParseRule<Self>] {
    [
      .s(".a", {
        try $0.map {
          try [$0.x(0) : $0.x(1)]
        }.dict { $0 }
      }),
    ]
  }
}

protocol JsBankParsable: PatchTruss {
  static var jsBankRules: [JsParseRule<SomeBankTruss<Self>>] { get }
}

extension SomeBankTruss: JsParsable where PT: JsBankParsable {
  static var jsRules: [JsParseRule<Self>] { PT.jsBankRules }
}
