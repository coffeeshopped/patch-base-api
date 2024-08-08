
import PBAPI
import JavaScriptCore

enum Match {
  case a([MatchItem])
  case obj(Dictionary<String,MatchItem>)
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


  func string() -> String {
    switch self {
    case .a(let items): return "[\(items.map { $0.string() }.joined(separator: ", "))]"
    case .single(let item): return item.string()
    case .obj(let dict): return "[\n\(dict.map { "\t\($0.key): \($0.value.string())" }.joined(separator: "\n"))\n]"
    }
  }
}

indirect enum MatchItem : Equatable, Hashable {
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
      return x.isString || x.isArray
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
    case .c(let str): return str
    case .opt(let item): return "\(item.string())?"
    default:
      return Self.prettyKeys[self] ?? "_"
    }
  }

  
}

struct JsParseTransform<Output:Any> {
  
  let match: Match
  let xform: (JSValue) throws -> Output
  
  init(_ match: Match, _ xform: @escaping (JSValue) throws -> Output) {
    self.match = match
    self.xform = xform
  }
    
  func transform(_ x: JSValue) throws -> Output {
    // first, check for match
    do {
      return try xform(x)
    }
    catch {
      throw JSError.wrap("Error in transform. Match was: \n\(match.string())\nJS Value:\n\(x.pbDebug())", error)
    }
  }
}


struct JsParseTransformSet<Output:Any> {
  let rules: [JsParseTransform<Output>]
  let name: String
  
  init(_ rules: [JsParseTransform<Output>], _ name: String) {
    self.rules = rules
    self.name = name
  }
  
  init(_ tuples: [(Any, (JSValue) throws -> Output)], _ name: String) throws {
    self.rules = try tuples.map {
      switch $0.0 {
      case let arr as [String]:
        return .init(try Match.from(arr), $0.1)
      case let dict as [String:String]:
        return .init(try Match.from(dict), $0.1)
      case let str as String:
        return .init(try Match.from(str), $0.1)
      case let arr as [Int]:
        return .init(try Match.from(arr), $0.1)
      default:
        throw JSError.error(msg: "Unrecognized Match specifier: \($0.0)")
      }
    }
    self.name = name
  }
  
}

extension JsParseTransform where Output: SysexTruss {
  
  func anyTrussXform() -> JsParseTransform<any SysexTruss> {
    .init(match, { try xform($0) as any SysexTruss })
  }
}

extension JsParseTransformSet where Output: JsParsable {

  func arrayParsers() throws -> JsParseTransformSet<[Output]> {
    try .init([
      (".a", {
        try $0.map { try $0.xform() }
      })
    ], "\(self.name) array")
  }

}

extension JsParseTransformSet where Output: SysexTruss {
  func anyTrussRules() -> [JsParseTransform<any SysexTruss>] {
    rules.map { $0.anyTrussXform() }
  }
}

protocol JsParsable {
  static var jsParsers: JsParseTransformSet<Self> { get }
}

protocol JsArrayParsable {
  static var jsArrayParsers: JsParseTransformSet<[Self]> { get }
}

extension Array: JsParsable where Element: JsArrayParsable {
  static var jsParsers: JsParseTransformSet<Array<Element>> { Element.jsArrayParsers }
}

extension Dictionary: JsParsable where Key: JsParsable, Value: JsParsable {
  static var jsParsers: JsParseTransformSet<Dictionary<Key, Value>> {
    try! JsParseTransformSet<Self>([
      (".a", {
        try $0.map {
          [try $0.any(0).xform() : try $0.any(1).xform()]
        }.dict { $0 }
      }),
    ], "pairs")
  }
}

protocol JsBankParsable: PatchTruss {
  static var jsBankParsers: JsParseTransformSet<SomeBankTruss<Self>> { get }
}

extension SomeBankTruss: JsParsable where PT: JsBankParsable {
  static var jsParsers: JsParseTransformSet<SomeBankTruss<PT>> { PT.jsBankParsers }
}
