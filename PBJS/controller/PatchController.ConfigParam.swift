
import PBAPI

extension PatchController.ConfigParam: JsParsable {
  
  static let jsParsers: JsParseTransformSet<Self> = try! .init([
    (["fullPath", ".p"], {
      try .fullPath($0.x(1))
    }),
    (".d", {
      try .span($0.x())
    }),
  ])

}
