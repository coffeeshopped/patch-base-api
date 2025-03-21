import PBAPI

extension ValidBundle : JsParsable {
  
  static var jsRules: [JsParseRule<ValidBundle>] = [
    .d(["sizes": ".a"], { try .init(sizes: $0.x("sizes")) }),
  ]
}
