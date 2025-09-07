
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

  func x<Out:JsParsable>() throws -> Out { try xform(Out.jsRules) }
  func x<Out:JsParsable>(exportOrigin: String?) throws -> Out { try xform(Out.jsRules, exportOrigin: exportOrigin) }
  func x<Out:JsParsable>(_ k: String) throws -> Out { try any(k).x() }
  func x<Out:JsParsable>(_ i: Int) throws -> Out { try any(i).x() }

  func some(_ k: String) -> JSValue? {
    guard let e = try? any(k) else { return nil }
    return (e.isNull || e.isUndefined) ? nil : e
  }

  func some(_ i: Int) -> JSValue? {
    guard let e = try? any(i) else { return nil }
    return (e.isNull || e.isUndefined) ? nil : e
  }

  // look for a value at the given key.
  // if it exists, parse an expected type
  // if it doesn't exist, return nil
  // used for optional (but type-checked) values
//  func x<Out:JsParsable>(_ k: String) throws -> Out? {
//    try some(k)?.x()
//  }
//  func x<Out:JsParsable>(_ i: Int) throws -> Out? {
//    try some(i)?.x()
//  }

  func xq<Out:JsParsable>(_ k: String) throws -> Out? {
    try some(k)?.x()
  }
  func xq<Out:JsParsable>(_ i: Int) throws -> Out? {
    try some(i)?.x()
  }
    
  func num() throws -> NSNumber {
    guard isNumber else { throw JSError.error(msg: "Expected Number") }
    return toNumber()
  }
  
  func arr(_ index: Int) throws -> JSValue {
    let item = try any(index)
    guard item.isArray else { throw JSError.error(msg: "Expected Array at index") }
    return item
  }
    
  func map<X:Any>(_ fn: (JSValue) throws -> X) throws -> [X] {
    try (0..<arrCount()).map { try fn(any($0)) }
  }

  func flatMap<X:Any>(_ fn: (JSValue) throws -> [X]) throws -> [X] {
    try (0..<arrCount()).flatMap { try fn(any($0)) }
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

  func fnq(_ index: Int) throws -> JSValue? {
    guard let item = some(index) else { return nil }
    guard item.isFn else { throw JSError.error(msg: "Expected Function at index: \(index)") }
    return item
  }

  func xform<Output:Any>(_ rules: [JsParseRule<Output>], exportOrigin: String? = nil) throws -> Output {
    let exportOrigin = exportOrigin ?? self.exportOrigin()
    guard let rule = rules.first(where: { $0.matches(self) }) else {
      // TODO: make a prettier printed version of Output.self, removing PBAPI and using short-form syntax for Array and Dictionary
      throw JSError.noParseRule(parseRuleSetName: (Output.self as? any JsParsable.Type)?.jsName() ?? String(reflecting: Output.self), value: self, exportOrigin: exportOrigin)
    }
    // TODO: catch and wrap any exceptions here to denote what rule was tried, with what data.
    return try rule.transform(self)
  }

  func x<A:JsParsable, B:JsParsable>() throws -> (A, B) {
    let t: JsParseRule<(A,B)> = .arr([A.self, B.self], { (try $0.x(0), try $0.x(1)) }, "(\(A.jsName()).\(B.jsName()))")
    return try t.transform(self)
  }

  func x<A:JsParsable, B:JsParsable>() throws -> [(A, B)] {
    let t: JsParseRule<[(A,B)]> = .arr([JsObj.self], { try $0.map { try ($0.x(0), $0.x(1)) } }, "[(\(A.jsName()).\(B.jsName()))]")
    return try t.transform(self)
  }

  func x<A:JsParsable, B:JsParsable>(_ key: String) throws -> [(A, B)] {
    try any(key).x()
  }

//  func x<Output:JsParsable>() throws -> [(SynthPath, Output)] {
//    let t: JsParseRule<(SynthPath, Output)> = .a([".p", ".x"], { (try $0.x(0), try $0.x(1)) })
//    return try map { try t.transform($0) }
//  }

  /// The JS file (if any) that this Value was exported from.
  public func exportOrigin() -> String? { try? x("EXPORT_ORIGIN") }
  public func setExportOrigin(_ str: String) throws {
    self.defineProperty("EXPORT_ORIGIN", descriptor: [
      JSPropertyDescriptorValueKey : str
    ])
    if isArray {
      try forEach {
        try $0.setExportOrigin(str)
      }
    }
  }

  public func pbDebug(_ indent: Int = 0, depth: Int = 1) -> String {
    if isString {
      return "\"\(toString()!)\""
    }
    else if isArray {
//      return debugDescription
      if depth > 0 {
        var str = "[ "
        str.append(try! map {
          $0.pbDebug(indent, depth: depth - 1)
        }.joined(separator: ", "))
        str.append(" ]")
        return str
      }
      else {
        return "Array"
      }
    }
    else if isNumber {  
      return toString()
    }
    else if isFn {
      return debugDescription
    }
    else if isObject {
      if depth > 0 {
        let inStr = String(repeating: "  ", count: indent)
        var str = "\(inStr){\n"
        toDictionary().keys.forEach {
          str.append("\(inStr)\t\($0): ")
          str.append(forProperty("\($0)").pbDebug(indent + 1, depth: depth - 1))
          str.append("\n")
        }
        str.append("\(inStr)}")
        return str
      }
      else {
        return "Object"
      }
    }
    return debugDescription
  }
  
  func xformArr<Output:Any>(_ rules: [JsParseRule<Output>]) throws -> [Output] {
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
  
  func fn(_ key: String) throws -> JSValue {
    guard let item = try checkForProperty(key),
          item.isFn else { throw JSError.error(msg: "Expected Function at key: \(key)") }
    return item
  }
  
  func fnq(_ key: String) throws -> JSValue? {
    guard let item = some(key) else { return nil }
    guard item.isFn else { throw JSError.error(msg: "Expected Function at key: \(key)") }
    return item
  }

  
  // MARK: Automatic function signature parsing!
  
  // int-based
  
  func fn<A:JsPassable, B:JsParsable>(_ index: Int) throws -> ((A) throws -> B) {
    try fn(fn(index))
  }

  func fn<A:JsPassable, B:JsParsable, C:JsPassable>(_ index: Int) throws -> ((A, C) throws -> B) {
    try fn(fn(index))
  }
  
  func fn<A:JsPassable, B:JsParsable, C:JsPassable, D:JsPassable>(_ index: Int) throws -> ((A, C, D) throws -> B) {
    try fn(fn(index))
  }

  func fnq<A:JsPassable, B:JsParsable>(_ index: Int) throws -> ((A) throws -> B)? {
    guard let f = try fnq(index) else { return nil }
    return try fn(f)
  }

  func fnq<A:JsPassable, B:JsParsable, C:JsPassable>(_ index: Int) throws -> ((A, C) throws -> B)? {
    guard let f = try fnq(index) else { return nil }
    return try fn(f)
  }

  func fnq<A:JsPassable, B:JsParsable, C:JsPassable, D:JsPassable>(_ index: Int) throws -> ((A, C, D) throws -> B)? {
    guard let f = try fnq(index) else { return nil }
    return try fn(f)
  }

  // key-based
  
  func fn<A:JsPassable, B:JsParsable>(_ key: String) throws -> ((A) throws -> B) {
    try fn(fn(key))
  }

  func fn<A:JsPassable, B:JsParsable, C:JsPassable>(_ key: String) throws -> ((A, C) throws -> B) {
    try fn(fn(key))
  }
  
  func fn<A:JsPassable, B:JsParsable, C:JsPassable, D:JsPassable>(_ key: String) throws -> ((A, C, D) throws -> B) {
    try fn(fn(key))
  }
  
  func fnq<A:JsPassable, B:JsParsable>(_ key: String) throws -> ((A) throws -> B)? {
    guard let f = try fnq(key) else { return nil }
    return try fn(f)
  }

  func fnq<A:JsPassable, B:JsParsable, C:JsPassable>(_ key: String) throws -> ((A, C) throws -> B)? {
    guard let f = try fnq(key) else { return nil }
    return try fn(f)
  }

  func fnq<A:JsPassable, B:JsParsable, C:JsPassable, D:JsPassable>(_ key: String) throws -> ((A, C, D) throws -> B)? {
    guard let f = try fnq(key) else { return nil }
    return try fn(f)
  }


  private func fn<A:JsPassable, B:JsParsable>(_ f: JSValue) throws -> ((A) throws -> B) {
    let exportOrigin = self.exportOrigin()
    return {
      try f.call([$0.toJS()], exportOrigin: exportOrigin).x(exportOrigin: exportOrigin)
    }
  }

  // for 2-arg fns
  private func fn<A:JsPassable, B:JsParsable, C:JsPassable>(_ f: JSValue) throws -> ((A, C) throws -> B) {
    let exportOrigin = self.exportOrigin()
    return {
      try f.call([$0.toJS(), $1.toJS()], exportOrigin: exportOrigin).x(exportOrigin: exportOrigin)
    }
  }

  // for 3-arg fns
  private func fn<A:JsPassable, B:JsParsable, C:JsPassable, D:JsPassable>(_ f: JSValue) throws -> ((A, C, D) throws -> B) {
    let exportOrigin = self.exportOrigin()
    return {
      try f.call([$0.toJS(), $1.toJS(), $2.toJS()], exportOrigin: exportOrigin).x(exportOrigin: exportOrigin)
    }
  }

  
  var isFn: Bool {
    !isUndefined && call(withArguments: []) != nil
  }
  
  // calls as a function, throwing any JS Exceptions
  func call(_ args: [Any], exportOrigin: String?) throws -> JSValue! {
    context.exception = nil
    let value = call(withArguments: args)!
    let exportOrigin = exportOrigin ?? self.exportOrigin()
    if let exc = context.exception {
      throw JSError.fnException(fn: self, exception: exc, exportOrigin: exportOrigin)
    }
    if let exportOrigin = exportOrigin {
      try value.setExportOrigin(exportOrigin)
    }
    return value
  }

}

