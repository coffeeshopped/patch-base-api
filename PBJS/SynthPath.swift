
import JavaScriptCore
import PBAPI

extension SynthPathItem: JsParsable {
  
  public static let jsRules: [JsParseRule<Self>] = [
    .t(String.self, {
      try parseSynthPathItem($0.x())
    })
  ]

  public static let jsArrayRules: [JsParseRule<[Self]>] = [
    .t(String.self, {
      try $0.toString().split(separator: "/").map {
        guard let i = Int($0) else {
          return try parseSynthPathItem(String($0))
        }
        return .i(i)
      }
    }),
    .t(Int.self, { [.i(try $0.x())] }),
    .t([JsObj].self, { try $0.flatMap { try $0.x() } }),
  ]

  fileprivate static func parseSynthPathItem(_ s: String) throws -> Self {
    guard let i = SynthPathItem.parseMap[s] else {
      throw JSError.error(msg: "Unknown Synth Path element: \(s)")
    }
    return i
  }
  
}

extension SynthPath : JsParsable {
  
  public static let jsRules: [JsParseRule<Self>] = [
    .t(String.self, {
      let items = try $0.toString().split(separator: "/").map {
        guard let i = Int($0) else {
          return try SynthPathItem.parseSynthPathItem(String($0))
        }
        return .i(i)
      }
      return SynthPath(items)
    }),
    .t(Int.self, { [.i(try $0.x())] }),
    .t([JsObj].self, { .init(try $0.flatMap { try $0.x() }) })
  ]

  public static let jsArrayRules: [JsParseRule<[Self]>] = [
    .a(">", [[Parm].self, SynthPathMap.self], { v in
      // expect elem 1 to be Parms
      let parms: [Parm] = try v.x(1)
      // the rest should be SynthPathMap fns
      let maps: [SynthPathMap] = try (2..<v.arrCount()).map {
        try v.x($0)
      }
      // feed the parm paths through the chain of SynthPathMaps
      return try maps.reduce(parms.map { $0.path }) { partialResult, m in
        try partialResult.compactMap { try m.call($0) }
      }
    }),
  ]
  

}

extension SynthPath : JsPassable {
  func toJS() -> AnyHashable { str() }
}

enum JsSynthPath {
  
  static let pathEq: @convention(block) (JSValue, JSValue) -> Bool = {
    let p1: SynthPath = try! $0.x()
    let p2: SynthPath = try! $1.x()
    return p1 == p2
  }

  static let pathLen: @convention(block) (JSValue) -> Int = {
    do {
      let p1: SynthPath = try $0.x()
      return p1.count
    } catch let error {
      JsModuleProvider.setException($0, "pathLen: passed value is not a valid path: \($0.pbDebug())")
    }
    return -1
  }

  static let pathPart: @convention(block) (JSValue, JSValue) -> AnyHashable = {
    do {
      let p: SynthPath = try $0.x()
      let index: Int = try $1.x()
      return p[index].scriptItem()
    }
    catch {
      JsModuleProvider.setException($0, "pathPart: error: \($0.pbDebug())")
    }
    return ""
  }
  
  static let pathLast: @convention(block) (JSValue) -> AnyHashable = {
    do {
      let p: SynthPath = try $0.x()
      return p.last?.scriptItem()
    }
    catch {
      JsModuleProvider.setException($0, "pathLast: passed value is not a valid path: \($0.pbDebug())")
    }
    return ""
  }

}
