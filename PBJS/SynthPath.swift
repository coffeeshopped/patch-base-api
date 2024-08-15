
import JavaScriptCore
import PBAPI

extension SynthPathItem: JsArrayParsable {
  
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
}

extension SynthPath {
  
  func toJS() -> [Any] {
    map {
      switch $0 {
      case .i(let i):
        return i
      default:
        return "\($0)"
      }
    }
  }
  
  func str() -> String {
    var s = ""
    forEach { s.append("\($0)")}
    return s
  }
  
}

enum JsSynthPath {
  
  static let pathEq: @convention(block) (JSValue, JSValue) -> Bool = {
    let p1 = try! $0.path()
    let p2 = try! $1.path()
    return p1 == p2
  }

}
