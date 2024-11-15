
import JavaScriptCore
import PBAPI

extension SynthPathItem: JsArrayParsable {
  
  static var jsParsers: JsParseTransformSet<Self> = try! .init([
    (".s", { 
      let s: String = try $0.x()
      return try parseSynthPathItem(s)
    })
  ])
  
  static let jsArrayParsers: JsParseTransformSet<[Self]> = try! .init([
    (".s", {
      try $0.toString().split(separator: "/").map {
        guard let i = Int($0) else {
          return try parseSynthPathItem(String($0))
        }
        return .i(i)
      }
    }),
    (".n", { [.i(try $0.x())] }),
    (".a", { try $0.flatMap { try $0.x() } })
  ], "SynthPath")

  private static func parseSynthPathItem(_ s: String) throws -> Self {
    guard let i = SynthPathItem.parseMap[s] else {
      throw JSError.error(msg: "Unknown Synth Path element: \(s)")
    }
    return i
  }
  
  func scriptItem() -> AnyHashable {
    switch self {
    case .i(let i):
      return i
    default:
      return "\(self)"
    }
  }
}

extension SynthPath : JsPassable {
  func toJS() -> AnyHashable { str() }
  func str() -> String { map { "\($0.scriptItem())" }.joined(separator: "/") }
  
  static let arrPathRules: JsParseTransformSet<[SynthPath]> = try! .init([
    ([">", ".x"], { v in
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
    (".a", { try $0.map { try $0.x() } }),
  ])
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
      JsModuleWerk.setException($0, "pathLen: passed value is not a valid path: \($0.pbDebug())")
    }
    return -1
  }

  static let pathPart: @convention(block) (JSValue, JSValue) -> AnyHashable = {
    let p: SynthPath = try! $0.x()
    let index: Int = try! $1.x()
    return p[index].scriptItem()
  }

}
