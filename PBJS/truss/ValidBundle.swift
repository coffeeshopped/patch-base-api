import PBAPI

extension ValidBundle : JsParsable {
  
  static var jsParsers: JsParseTransformSet<Self> = try! .init([
    (["sizes": ".a"], { try .init(sizes: $0.x("sizes")) }),
  ])
}
