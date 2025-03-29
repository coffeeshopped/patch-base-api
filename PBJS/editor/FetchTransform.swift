
import PBAPI
import JavaScriptCore

extension FetchTransform: JsParsable {
  
  static let jsRules: [JsParseRule<Self>] = [
    .a(["sequence", ".x",], { .sequence(try $0.x(1)) }),
    .a(["truss", ".x"], {
      try .truss($0.x(1))
    }),
    .a(["bankTruss", ".x"], {
      try .bankTruss($0.x(1), waitInterval: 0)
    }),
    .a(["custom", ".x"], {
      let fns = try $0.any(1).map {
        try $0.xform(RxMidi.FetchCommand.dynamicRules)
      }
      return .custom({ editor in try fns.map { try $0(editor) } })
    }),
  ]
    
}
