import PBAPI

extension SynthPathMap : JsParsable {
  
  static let jsRules: [JsParseRule<Self>] = [
    .a(["removePrefix", ".p"], { try .removePrefix($0.x(1)) }),
    .a(["from", ".n"], { try .from($0.x(1)) }),
    .a(["fn", ".f"], { try .fn($0.fn(1)) }),
  ]
  
}
