import PBAPI

extension SynthPathMap : JsParsable {
  
  static let jsRules: [JsParseRule<Self>] = [
    (["removePrefix", ".p"], { try .removePrefix($0.x(1)) }),
    (["from", ".n"], { try .from($0.x(1)) }),
    (["fn", ".f"], { try .fn($0.fn(1)) }),
  ])
  
}
