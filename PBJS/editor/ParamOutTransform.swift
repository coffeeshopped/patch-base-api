
import PBAPI

extension ParamOutTransform : JsParsable {
  
  static let jsRules: [JsParseRule<Self>] = [
    .a(["bankNames", ".p"], {
      try .bankNames($0.x(1), nameBlock: nil)
    }),
    .a(["patchOut", ".f"], {
      let fn = try $0.fn(1)
      let exportOrigin = fn.exportOrigin()
      return .patchOut { change, patch in
        do {
          return try fn.call([change.toJS(), patch], exportOrigin: exportOrigin).x()
        }
        catch {
          throw JSError.wrap("in 'patchOut' JS function", error)
        }
      }
    }),
  ]

}
