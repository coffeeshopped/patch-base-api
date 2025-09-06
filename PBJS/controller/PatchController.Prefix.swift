
import PBAPI

extension PatchController.Prefix: JsParsable {
  
  public static let jsRules: [JsParseRule<Self>] = [
    .d(["fixed" : SynthPath.self], { try .fixed($0.x("fixed")) }),
    .d(["index" : SynthPath.self], { try .index($0.x("index")) }),
    .d(["indexFn" : JsFn.self], { try .indexFn($0.fn("indexFn")) }),
  ]
  
}
