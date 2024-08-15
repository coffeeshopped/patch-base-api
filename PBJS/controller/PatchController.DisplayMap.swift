
import PBAPI

extension PatchController.DisplayMap: JsParsable, JsArrayParsable {
  
  static let jsParsers: JsParseTransformSet<Self> = try! .init([
    (["src", ".p", ".f"], {
      let fn = try $0.fn(2)
      return .src(try $0.path(1), dest: nil) {
        try fn.call([$0]).cgFloat()
      }
    }),
    (["u", ".p", ".n", ".p?"], {
      .unit(try $0.path(1), dest: try $0.xform(3), max: try $0.cgFloat(2))
    }),
  ])

  static let jsArrayParsers = try! jsParsers.arrayParsers()
  
}
