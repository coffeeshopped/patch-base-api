
import PBAPI
import JavaScriptCore

extension FetchTransform: JsParsable {
  
  static let jsRules: [JsParseRule<Self>] = [
    .a(["sequence", ".x",], { .sequence(try $0.x(1)) }),
    .a(["truss", ".x"], {
      let fn: SinglePatchTruss.Core.ToMidiFn = try $0.x(1)
      return .truss({ try fn.call([], $0).bytes() })
    }),
    .a(["bankTruss", ".x"], {
      let fn: SinglePatchTruss.Core.ToMidiFn = try $0.x(1)
      return .bankTruss({ editor, loc in try fn.call([loc], editor).bytes() }, waitInterval: 0)
    }),
    .a(["custom", ".x"], {
      let fns = try $0.any(1).map {
        try $0.xform(RxMidi.FetchCommand.dynamicRules)
      }
      return .custom({ editor in try fns.map { try $0(editor) } })
    }),
  ]
    
}
