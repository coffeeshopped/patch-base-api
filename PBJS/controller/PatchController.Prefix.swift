
import PBAPI

extension PatchController.Prefix: JsParsable {
  
  static var jsRules: [JsParseRule<PatchController.Prefix>] = [
    .d(["fixed" : ".p"], { try .fixed($0.x("fixed")) }),
    .d(["index" : ".p"], { try .index($0.x("index")) }),
    .d(["indexFn" : ".f"], { try .indexFn($0.fn("indexFn")) }),
  ]

}
