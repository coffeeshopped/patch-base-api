
import PBAPI

extension PatchController.Prefix: JsParsable {
  
  static let nuJsRules: [NuJsParseRule<Self>] = [
    .d(["fixed" : SynthPath.self], { try .fixed($0.x("fixed")) }),
    .d(["index" : SynthPath.self], { try .index($0.x("index")) }),
    .d(["indexFn" : JsFn.self], { try .indexFn($0.fn("indexFn")) }),
  ]
  
  static var jsRules: [JsParseRule<PatchController.Prefix>] = [
    .d(["fixed" : ".p"], { try .fixed($0.x("fixed")) }),
    .d(["index" : ".p"], { try .index($0.x("index")) }),
    .d(["indexFn" : ".f"], { try .indexFn($0.fn("indexFn")) }),
  ]

}
