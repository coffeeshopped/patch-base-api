
import PBAPI

extension ParamOutTransform : JsArrayParsable {
  
  static let jsParsers: JsParseTransformSet<Self> = try! .init([
    ([".p", ".a"], { try .init($0.x(0), $0.x(1)) }),
  ])
  
  static let jsArrayParsers = try! jsParsers.arrayParsers()
}

extension ParamOutTransform.Transform : JsParsable {

  static let jsParsers: JsParseTransformSet<Self> = try! .init([
    (["bankNames", ".p", ".p"], {
      try .bankNames($0.x(1), $0.x(2), nameBlock: nil)
    }),
    (["patchOut", ".p", ".f"], {
      let fn = try $0.fn(2)
      let exportOrigin = fn.exportOrigin()
      return try .patchOut($0.x(1)) { change, patch in
        try fn.call([change, patch], exportOrigin: exportOrigin).x()
      }
    }),
  ])

}
