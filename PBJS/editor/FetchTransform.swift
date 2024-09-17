
import PBAPI
import JavaScriptCore

extension FetchTransform: JsParsable, JsArrayParsable {
  
  static let jsParsers: JsParseTransformSet<Self> = try! .init([
    (["sequence", ".x",], { .sequence(try $0.x(1)) }),
    (["truss", ".x"], {
      let fn: SinglePatchTruss.Core.ToMidiFn = try $0.x(1)
      return .truss({ try fn.call([], $0).bytes() })
    }),
    (["bankTruss", ".x"], {
      let fn: SinglePatchTruss.Core.ToMidiFn = try $0.x(1)
      return .bankTruss({ editor, loc in try fn.call([loc], editor).bytes() }, waitInterval: 0)
    }),
    (["custom", ".x"], {
      let fns = try $0.any(1).map {
        try $0.xform(RxMidi.FetchCommand.dynamicRules)
      }
      return .custom({ editor in try fns.map { try $0(editor) } })
    }),
  ], "fetch Transform")
  
  static let jsArrayParsers = try! jsParsers.arrayParsers()
  
}
