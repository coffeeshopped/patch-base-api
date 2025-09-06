
import PBAPI

extension EditorValueTransform : JsParsable {
  
  static let jsRules: [JsParseRule<Self>] = [
    .a("e", [SynthPath.self, SynthPath.self], optional: [Int.self], {
      try .value($0.x(1), $0.x(2), defaultValue: $0.xq(3) ?? 0)
    }), // returns editorValue
    .s("channel", { _ in .basicChannel }),
  ]
  
}
