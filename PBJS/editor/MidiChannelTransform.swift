
import PBAPI

extension MidiChannelTransform: JsParsable {
  
  static let jsRules: [JsParseRule<Self>] = [
    .s("basic", { _ in .basic(map: nil) }),
    .a("basic", [JsFn.self], {
      try .basic(map: $0.fn(1))
    }),
    .a("patch", [SynthPath.self, SynthPath.self], optional: [JsFn.self], {
      try .patch($0.x(1), $0.x(2), map: $0.fnq(3))
    }),
    .a("custom", [[EditorValueTransform].self, JsFn.self], {
      try .custom($0.x(1), $0.fn(2))
    }),
  ]
    
}
