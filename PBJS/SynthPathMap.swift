import PBAPI

extension SynthPathMap : JsParsable {
  
  static let nuJsRules: [NuJsParseRule<Self>] = [
    .a("removePrefix", [SynthPath.self], { try .removePrefix($0.x(1)) }),
    .a("from", [Int.self], { try .from($0.x(1)) }),
    .a("fn", [JsFn.self], { try .fn($0.fn(1)) }),
  ]
  
  static let jsRules: [JsParseRule<Self>] = [
    .a(["removePrefix", ".p"], { try .removePrefix($0.x(1)) }),
    .a(["from", ".n"], { try .from($0.x(1)) }),
    .a(["fn", ".f"], { try .fn($0.fn(1)) }),
  ]
  
}
