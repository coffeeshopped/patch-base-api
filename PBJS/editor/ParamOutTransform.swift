
import PBAPI

extension ParamOutTransform : JsParsable {
  
  static let nuJsRules: [NuJsParseRule<Self>] = [
    .a("bankNames", [SynthPath.self, SynthPath.self], {
      try .bankNames($0.x(1), $0.x(2), nameBlock: nil)
    }),
    .a("patchOut", [SynthPath.self, JsFn.self], {
      let fn = try $0.fn(2)
      let exportOrigin = fn.exportOrigin()
      return try .patchOut($0.x(1)) { change, patch in
        do {
          return try fn.call([change.toJS(), patch], exportOrigin: exportOrigin).x()
        }
        catch {
          throw JSError.wrap("in 'patchOut' JS function", error)
        }
      }
    }),
  ]
  
  static let jsRules: [JsParseRule<Self>] = [
    .a(["bankNames", ".p", ".p"], {
      try .bankNames($0.x(1), $0.x(2), nameBlock: nil)
    }),
    .a(["patchOut", ".p", ".f"], {
      let fn = try $0.fn(2)
      let exportOrigin = fn.exportOrigin()
      return try .patchOut($0.x(1)) { change, patch in
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
