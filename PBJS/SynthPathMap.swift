import PBAPI

extension SynthPathMap : JsParsable {
  
  static let jsRules: [JsParseRule<Self>] = [
    .a("removePrefix", [SynthPath.self], { try .removePrefix($0.x(1)) }),
    .a("from", [Int.self], { try .from($0.x(1)) }),
    .a("fn", [JsFn.self], { try .fn($0.fn(1)) }),
  ]
  
}
