
import PBAPI

extension PatchController.DisplayMap: JsParsable {
  
  static let jsRules: [JsParseRule<Self>] = [
    .a("src", [SynthPath.self, JsFn.self], {
      return try .src($0.x(1), dest: nil, $0.fn(2))
    }),
    .a("src", [SynthPath.self, SynthPath.self], optional: [JsFn.self], {
      if let fn = try? $0.fn(3) {
        return try .src($0.x(1), dest: $0.x(2), $0.fn(3))
      }
      else {
        return try .src($0.x(1), dest: $0.x(2)) { $0 }
      }
    }),
    .a("u", [SynthPath.self, CGFloat.self], optional: [SynthPath.self], {
      try .unit($0.x(1), dest: $0.xq(3), max: $0.x(2))
    }),
    .a("u", [SynthPath.self], optional: [SynthPath.self], {
      try .unit($0.x(1), dest: $0.xq(2))
    }),
    .a("=", [SynthPath.self], optional: [SynthPath.self], {
      try .ident($0.x(1), dest: $0.xq(2))
    }),
  ]
  
}
