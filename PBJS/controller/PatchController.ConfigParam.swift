
import PBAPI

extension PatchController.ConfigParam: JsParsable {
  
  static let nuJsRules: [NuJsParseRule<Self>] = [
    .a("fullPath", [SynthPath.self], {
      try .fullPath($0.x(1))
    }),
    .t(Parm.Span.self, {
      try .span($0.x())
    }),
  ]
  
  static let jsRules: [JsParseRule<Self>] = [
    .a(["fullPath", ".p"], {
      try .fullPath($0.x(1))
    }),
    .s(".d", {
      try .span($0.x())
    }),
  ]

}
