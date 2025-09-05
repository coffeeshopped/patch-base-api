import PBAPI

extension ValidBundle : JsParsable {
  
  static let nuJsRules: [NuJsParseRule<Self>] = [
    .d(["sizes": [Int].self], { try .init(sizes: $0.x("sizes")) }),
  ]
  
  static var jsRules: [JsParseRule<ValidBundle>] = [
    .d(["sizes": ".a"], { try .init(sizes: $0.x("sizes")) }),
  ]
}
