import PBAPI

extension ValidBundle : JsParsable {
  
  static let jsRules: [JsParseRule<Self>] = [
    .d(["sizes": [Int].self], { try .init(sizes: $0.x("sizes")) }),
  ]
  
}
