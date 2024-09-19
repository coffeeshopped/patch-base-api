
import PBAPI

extension PatchController.Prefix: JsParsable {
  
  static let jsParsers: JsParseTransformSet<PatchController.Prefix> = try! .init([
    (["fixed" : ".p"], { .fixed(try $0.x("fixed")) }),
    (["index" : ".p"], { .index(try $0.x("index")) }),
  ])

}
