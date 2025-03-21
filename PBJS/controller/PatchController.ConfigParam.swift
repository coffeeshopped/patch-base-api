
import PBAPI

extension PatchController.ConfigParam: JsParsable {
  
  static let jsRules: [JsParseRule<Self>] = [
    .a(["fullPath", ".p"], {
      try .fullPath($0.x(1))
    }),
    .s(".d", {
      try .span($0.x())
    }),
  ]

}
