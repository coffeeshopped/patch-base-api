
import PBAPI

extension PatchController.ConfigParam: JsParsable {
  
  static let jsRules: [JsParseRule<Self>] = [
    (["fullPath", ".p"], {
      try .fullPath($0.x(1))
    }),
    (".d", {
      try .span($0.x())
    }),
  ])

}
