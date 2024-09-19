
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
    (".a", {
      try $0.map {
        guard $0.isNumber else {
          return try parseSynthPathItem($0.toString())
        }
        return .i(Int($0.toInt32()))
      }
    })
  ], "SynthPath")

  private static func parseSynthPathItem(_ s: String) throws -> Self {
    guard let i = SynthPathItem.parseMap[s] else {
      throw JSError.error(msg: "Unknown Synth Path element: \(s)")
    }
    return i
  }
  
  func scriptItem() -> Any {
    switch self {
    case .i(let i):
      return i
    default:
      return "\(self)"
    }
  }
}

extension SynthPath {
  func toJS() -> [Any] { map { $0.scriptItem() } }
  func str() -> String { map { "\($0.scriptItem())" }.joined(separator: "/") }
}

extension Dictionary<SynthPath,Int> {
  func toJS() -> [String:Int] {
    dict { [$0.key.str() : $0.value] }
  }
}

enum JsSynthPath {
  
  static let pathEq: @convention(block) (JSValue, JSValue) -> Bool = {
    let p1: SynthPath = try! $0.x()
    let p2: SynthPath = try! $1.x()
    return p1 == p2
  }

}
