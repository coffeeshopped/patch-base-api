
import JavaScriptCore
import PBAPI

extension JSValue {
    
  fileprivate func checkArr() throws {
    guard isArray else {
      throw JSError.error(msg: "Expected Array")
    }
  }
    
  func checkFn() throws {
    guard isFn else { throw JSError.error(msg: "Expected a function.") }
  }
  
  func any(_ index: Int) throws -> JSValue {
    try checkArr()
    
    guard arrCount() > index else { throw JSError.error(msg: "Array length should be at least \(index + 1)") }
    
    return atIndex(index)
  }
  
  func any(_ key: String) throws -> JSValue {
    guard let s = try checkForProperty(key) else { throw JSError.error(msg: "Expected property at key: \(key)") }
    return s
  }

  func x<Out:JsParsable>() throws -> Out { try xform(Out.jsParsers) }
  func x<Out:JsParsable>(_ k: String) throws -> Out { try any(k).x() }
  func x<Out:JsParsable>(_ i: Int) throws -> Out { try any(i).x() }

  // look for a value at the given key.
  // if it exists, parse an expected type
  // if it doesn't exist, return nil
  // used for optional (but type-checked) values
  func xq<Out:JsParsable>(_ k: String) throws -> Out? {
    guard let e = try? any(k), !e.isNull else { return nil }
    return try e.x()
  }
  func xq<Out:JsParsable>(_ i: Int) throws -> Out? {
    guard let e = try? any(i), !e.isNull else { return nil }
    return try e.x()
  }
    
  fileprivate func num() throws -> NSNumber {
    guard isNumber else { throw JSError.error(msg: "Expected Number") }
    return toNumber()
  }
  
  func arr(_ index: Int) throws -> JSValue {
    let item = try any(index)
    guard item.isArray else { throw JSError.error(msg: "Expected Array at index") }
    return item
  }
  
  func arrStr() throws -> [String] {
    try map { try $0.x() }
  }

  func arrStr(_ key: String) throws -> [String] { try arr(key).arrStr() }
  func arrStr(_ index: Int) throws -> [String] { try arr(index).arrStr() }
  
  func map<X:Any>(_ fn: (JSValue) throws -> X) throws -> [X] {
    try (0..<arrCount()).map { try fn(any($0)) }
  }
  
  func forEach(_ fn: (JSValue) throws -> Void) throws {
    try (0..<arrCount()).forEach { try fn(any($0)) }
  }
  
  
  func arrCount() -> Int {
    forProperty("length").toNumber().intValue
  }
  
  func obj(_ index: Int) throws -> JSValue {
    let item = try any(index)
    guard item.isObject else { throw JSError.error(msg: "Expected Object at index: \(index)") }
    return item
  }

  
  func fn(_ index: Int) throws -> JSValue {
    let item = try any(index)
    guard item.isFn else { throw JSError.error(msg: "Expected Function at index: \(index)") }
    return item
  }

  func fn<A:Any, B:JsParsable>(_ index: Int) throws -> ((A) throws -> B) {
    let f = try fn(index)
    return { try f.call([$0]).x() }
  }

  func xform<Output:Any>(_ rules: JsParseTransformSet<Output>) throws -> Output {
    guard let rule = rules.rules.first(where: { $0.match.matches(self) }) else {
      throw JSError.error(msg: "No matching rule in set: \(rules.name)\n\n\(pbDebug())")
    }
    // TODO: catch and wrap any exceptions here to denote what rule was tried, with what data.
    return try rule.transform(self)
  }


  func xform<A:JsParsable, B:JsParsable>() throws -> (A, B) {
    let t = try JsParseTransformSet<(A,B)>([
      ([".x", ".x"], { (try $0.any(0).x(), try $0.any(1).x()) }),
    ], "(\(A.self), \(B.self)) pairs")
    return try xform(t)
  }
  
  func xform<Output:JsParsable>() throws -> [(SynthPath, Output)] {
    let t = try JsParseTransformSet<(SynthPath, Output)>.init([
      ([".p", ".x"], { (try $0.x(0), try $0.x(1)) }),
    ], "(SynthPath, \(Output.self)) pairs")
    return try xformArr(t)
  }


  public func pbDebug(_ indent: Int = 0) -> String {
    if isString {
      return "\"\(toString()!)\""
    }
    else if isArray {
//      return debugDescription
      var str = "[ "
      str.append(try! map {
        $0.pbDebug(indent)
      }.joined(separator: ", "))
      str.append(" ]")
      return str
    }
    else if isNumber {  
      return toString()
    }
    else if isFn {
      return debugDescription
    }
    else if isObject {
            
      let inStr = String(repeating: "  ", count: indent)
      var str = "\(inStr){\n"
      toDictionary().keys.forEach {
        str.append("\(inStr)\t\($0): ")
        str.append(forProperty("\($0)").pbDebug(indent + 1))
        str.append("\n")
      }
      str.append("\(inStr)}")
      return str
    }
    return debugDescription
  }
  
  func xformArr<Output:Any>(_ rules: JsParseTransformSet<Output>) throws -> [Output] {
    try checkArr()
    return try map { try $0.xform(rules) }
  }
    
  fileprivate func checkForProperty(_ key: String) throws -> JSValue? {
    guard isObject else { throw JSError.error(msg: "Expected Object") }
    guard hasProperty(key) else { throw JSError.error(msg: "Object should have property '\(key)'") }
    return forProperty(key)
  }

  func arr(_ key: String) throws -> JSValue {
    guard let item = try checkForProperty(key),
          item.isArray else { throw JSError.error(msg: "Expected Array at key: \(key)") }
    return item
  }


  func arrInt() throws -> [Int] {
    try map { try $0.x() }
  }

  func arrInt(_ index: Int) throws -> [Int] { try arr(index).arrInt() }
  func arrInt(_ key: String) throws -> [Int] { try arr(key).arrInt() }
  
  func optDict() throws -> [Int:String] {
    try checkArr()
    let count = arrCount()
    return try (0..<count).dict {
      let arr = try arr($0)
      return [try arr.x(0) : try arr.x(1)]
    }
  }

  func obj(_ key: String) throws -> JSValue {
    guard let item = try checkForProperty(key),
          item.isObject else { throw JSError.error(msg: "Expected Object at key: \(key)") }
    return item
  }
  
  func arrPath() throws -> [SynthPath] {
    try map { try $0.x() }
  }
  
  func arrPath(_ key: String) throws -> [SynthPath] { try arr(key).arrPath() }
  func arrPath(_ index: Int) throws -> [SynthPath] { try arr(index).arrPath() }

  
  func fn(_ key: String) throws -> JSValue {
    guard let item = try checkForProperty(key),
          item.isFn else { throw JSError.error(msg: "Expected Function at key: \(key)") }
    return item
  }
  
  func fn<A:Any, B:JsParsable>(_ key: String) throws -> ((A) throws -> B) {
    let f = try fn(key)
    return { try f.call([$0]).x() }
  }

  
  var isFn: Bool {
    !isUndefined && call(withArguments: []) != nil
  }
  
  // calls as a function, throwing any JS Exceptions
  func call(_ args: [Any]) throws -> JSValue! {
    context.exception = nil
    let value = call(withArguments: args)
    if let exc = context.exception {
      let excStr = exc.toString() ?? "Unknown exception."
      throw JSError.error(msg: "JS Exception thrown when calling function: \(excStr)\n\(pbDebug())")
    }
    return value
  }

}

//protocol JSX {
//  static func x(_ v: JSValue) throws -> Self
//}

extension String: JsArrayParsable {
  static let jsParsers: JsParseTransformSet<Self> = try! .init([
    (".s", {
      guard $0.isString else {
        throw JSError.error(msg: "Expected String")
      }
      return $0.toString()
    }),
  ])
  
  static let jsArrayParsers: JsParseTransformSet<[Self]> = try! .init([
    ([".n", ".a"], {
      let count: Int = try $0.x(0)
      let iso: IsoFS = try $0.x(1)
      return (count).map { iso.forward(Float($0)) }
    }),
    (".a", { 
      try $0.map {
        try $0.x()
      }
    }),
  ])

}


extension Int: JsArrayParsable {
  static let jsParsers: JsParseTransformSet<Self> = try! .init([
    (".n", { try $0.num().intValue }),
  ])
  static let jsArrayParsers = try! jsParsers.arrayParsers()
}


extension UInt8: JsArrayParsable {
  static let jsParsers: JsParseTransformSet<Self> = try! .init([
    (".n", { try $0.num().uint8Value }),
  ])
  static let jsArrayParsers = try! jsParsers.arrayParsers()
}

extension Float: JsArrayParsable {
  static let jsParsers: JsParseTransformSet<Self> = try! .init([
    (".n", { try $0.num().floatValue }),
  ])
  static let jsArrayParsers = try! jsParsers.arrayParsers()
}

extension CGFloat: JsArrayParsable {
  static let jsParsers: JsParseTransformSet<Self> = try! .init([
    (".n", { CGFloat(truncating: try $0.num()) }),
  ])
  static let jsArrayParsers = try! jsParsers.arrayParsers()
}

extension Bool: JsArrayParsable {
  static let jsParsers: JsParseTransformSet<Self> = try! .init([
    (".b", {
      guard $0.isBoolean else { throw JSError.error(msg: "Expected Boolean") }
      return $0.toBool()
    }),
  ])
  static let jsArrayParsers = try! jsParsers.arrayParsers()
}

extension ClosedRange<Int> : JsParsable {
  static let jsParsers: JsParseTransformSet<Self> = try! .init([
    (".a", { try .init(($0.x(0))..<($0.x(1))) }),
  ])
}

//extension Array: JSX where Element: JSX {
//  static func x(_ v: JSValue) throws -> Array<Element> {
//    try v.map { try $0.x() }
//  }
//}

