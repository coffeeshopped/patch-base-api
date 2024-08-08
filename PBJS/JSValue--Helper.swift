
import JavaScriptCore
import PBAPI

extension JSValue {
  
  func str() throws -> String {
    guard isString else { throw JSError.error(msg: "Expected String") }
    return toString()
  }
  
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

  func str(_ index: Int) throws -> String {
    try any(index).str()
  }
  
  func num(_ index: Int) throws -> NSNumber {
    let s = try any(index)
    guard s.isNumber else {
      throw JSError.error(msg: "Expected Number at index: \(index)")
    }
    return s.toNumber()
  }
  
  func num() throws -> NSNumber {
    guard isNumber else {
      throw JSError.error(msg: "Expected Number")
    }
    return toNumber()
  }

  func int(_ index: Int) throws -> Int {
    try num(index).intValue
  }
  
  func int() throws -> Int { try num().intValue }

  func byte(_ index: Int) throws -> UInt8 {
    try num(index).uint8Value
  }

  func byte() throws -> UInt8 { try num().uint8Value }

  func cgFloat(_ index: Int) throws -> CGFloat {
    CGFloat(truncating: try num(index))
  }
  
  func cgFloat() throws -> CGFloat {
    guard isNumber else { throw JSError.error(msg: "Expected number")}
    return CGFloat(truncating: toNumber())
  }

  func arr(_ index: Int) throws -> JSValue {
    let item = try any(index)
    guard item.isArray else { throw JSError.error(msg: "Expected Array at index") }
    return item
  }
  
  func arrStr() throws -> [String] {
    try map { try $0.str() }
  }

  
  func map<X:Any>(_ fn: (JSValue) throws -> X) throws -> [X] {
    try (0..<arrCount()).map { try fn(any($0)) }
  }
  
  
  func arrCount() -> Int {
    forProperty("length").toNumber().intValue
  }
  
  func obj(_ index: Int) throws -> JSValue {
    let item = try any(index)
    guard item.isObject else { throw JSError.error(msg: "Expected Object at index: \(index)") }
    return item
  }

  
  func path(_ index: Int) throws -> SynthPath {
    try any(index).path()
  }
  
  func arrPath() throws -> [SynthPath] {
    try map { try $0.xform() }
  }
  
  func arrPath(_ key: String) throws -> [SynthPath] {
    try arr(key).arrPath()
  }

  
  func fn(_ index: Int) throws -> JSValue {
    let item = try any(index)
    guard item.isFn else { throw JSError.error(msg: "Expected Function at index: \(index)") }
    return item
  }


  func xform<Output:Any>(_ rules: JsParseTransformSet<Output>) throws -> Output {
    guard let rule = rules.rules.first(where: { $0.match.matches(self) }) else {
      throw JSError.error(msg: "No matching rule in set: \(rules.name)\n\n\(pbDebug())")
    }
    // TODO: catch and wrap any exceptions here to denote what rule was tried, with what data.
    return try rule.transform(self)
  }
  
  func xform<Output:JsParsable>() throws -> Output {
    try xform(Output.jsParsers)
  }

  func xform<Output:JsParsable>(_ key: String) throws -> Output {
    try any(key).xform()
  }

  func xform<Output:JsParsable>(_ index: Int) throws -> Output {
    try any(index).xform()
  }

  func xform<A:JsParsable, B:JsParsable>() throws -> (A, B) {
    let t = try JsParseTransformSet<(A,B)>([
      ([".x", ".x"], { (try $0.any(0).xform(), try $0.any(1).xform()) }),
    ], "pairs")
    return try xform(t)
  }
  
  func xform<Output:JsParsable>() throws -> [(SynthPath, Output)] {
    let t = try JsParseTransformSet<(SynthPath, Output)>.init([
      ([".p", ".x"], { (try $0.path(0), try $0.any(1).xform()) }),
    ], "pairs")
    return try xformArr(t)
  }


  func pbDebug(_ indent: Int = 0) -> String {
    if isString {
      return toString()
    }
    else if isArray {
      return debugDescription
    }
    else if isNumber {  
      return toString()
    }
    else if isFn {
      return debugDescription
    }
    else if isObject {
            
      let inStr = String(repeating: "\t", count: indent)
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

  func str(_ key: String) throws -> String {
    guard let s = try checkForProperty(key),
          s.isString else { throw JSError.error(msg: "Expected String at key: \(key)") }
    return s.toString()
  }

  func num(_ key: String) throws -> NSNumber {
    guard let s = try checkForProperty(key),
          s.isNumber else { throw JSError.error(msg: "Expected Number at key: \(key)") }
    return s.toNumber()
  }

  func bool() throws -> Bool {
    guard isBoolean else { throw JSError.error(msg: "Expected Boolean") }
    return toBool()
  }

  func bool(_ key: String) throws -> Bool { try any(key).bool() }
  func bool(_ index: Int) throws -> Bool { try any(index).bool() }

  func any(_ key: String) throws -> JSValue {
    guard let s = try checkForProperty(key) else { throw JSError.error(msg: "Expected property at key: \(key)") }
    return s
  }

  func int(_ key: String) throws -> Int {
    try num(key).intValue
  }
  
  func cgFloat(_ key: String) throws -> CGFloat {
    CGFloat(truncating: try num(key))
  }


  func arr(_ key: String) throws -> JSValue {
    guard let item = try checkForProperty(key),
          item.isArray else { throw JSError.error(msg: "Expected Array at key: \(key)") }
    return item
  }

  func arrStr(_ key: String) throws -> [String] {
    try arr(key).arrStr()
  }
  
  func arrInt() throws -> [Int] {
    try map { try $0.int() }
  }

  func arrInt(_ index: Int) throws -> [Int] { try arr(index).arrInt() }
  func arrInt(_ key: String) throws -> [Int] { try arr(key).arrInt() }

  func arrByte() throws -> [UInt8] {
    try map { try $0.byte() }
  }
  
  func optDict() throws -> [Int:String] {
    try checkArr()
    let count = arrCount()
    return try (0..<count).dict {
      let arr = try arr($0)
      return [try arr.int(0) : try arr.str(1)]
    }
  }

  func obj(_ key: String) throws -> JSValue {
    guard let item = try checkForProperty(key),
          item.isObject else { throw JSError.error(msg: "Expected Object at key: \(key)") }
    return item
  }
  
  func path() throws -> SynthPath { try xform() }
  
  func path(_ key: String) throws -> SynthPath { try any(key).path() }

  func fn(_ key: String) throws -> JSValue {
    guard let item = try checkForProperty(key),
          item.isFn else { throw JSError.error(msg: "Expected Function at key: \(key)") }
    return item
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

