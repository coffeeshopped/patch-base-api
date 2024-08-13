
import PBAPI
import JavaScriptCore

extension FetchTransform: JsParsable, JsArrayParsable {
  
  static let jsParsers: JsParseTransformSet<Self> = try! .init([
    (["sequence", ".x",], { .sequence(try $0.xform(1)) }),
    (["truss", ".x"], {
      let fn = try $0.any(1).xform(SinglePatchTruss.toMidiRules)
      return .truss({ try fn([], $0) })
    }),
    (["bankTruss", ".x"], {
      let fn = try $0.any(1).xform(SinglePatchTruss.toMidiRules)
      return .bankTruss({ editor, loc in try fn([loc], editor) }, waitInterval: 0)
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
