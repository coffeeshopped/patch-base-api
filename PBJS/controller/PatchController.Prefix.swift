
import PBAPI

extension PatchController.Prefix: JsParsable {
  
  static let jsParsers: JsParseTransformSet<PatchController.Prefix> = try! .init([
    (["fixed" : ".p"], { try .fixed($0.x("fixed")) }),
    (["index" : ".p"], { try .index($0.x("index")) }),
    (["indexFn" : ".f"], {
      return try .indexFn($0.fn("indexFn"))
    }),
  ])

}
