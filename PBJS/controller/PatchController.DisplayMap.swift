
import PBAPI

extension PatchController.DisplayMap: JsParsable {
  
  public static let jsRules: [JsParseRule<Self>] = [
    .a("src", [SynthPath.self, JsFn.self], optional: [SynthPath.self], {
      try .src($0.x(1), dest: $0.x(3), $0.fn(2))
    }),
    .a("u", [SynthPath.self, Float.self], optional: [SynthPath.self], {
      try .unit($0.x(1), dest: $0.xq(3), max: $0.x(2))
    }),
    .a("u", [SynthPath.self], optional: [SynthPath.self], {
      try .unit($0.x(1), dest: $0.xq(2))
    }, "uDefault"),
    .a("=", [SynthPath.self], optional: [SynthPath.self], {
      try .ident($0.x(1), dest: $0.xq(2))
    }),
  ]
  
}
