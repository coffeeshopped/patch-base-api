
import PBAPI

extension PatchController.DisplayMap: JsParsable, JsArrayParsable {
  
  static let jsParsers: JsParseTransformSet<Self> = try! .init([
    (["src", ".p", ".f"], {
      let fn = try $0.fn(2)
      return .src(try $0.path(1), dest: nil) {
        try fn.call([$0]).cgFloat()
      }
    }),
  ], "controller display map")

  static let jsArrayParsers = try! jsParsers.arrayParsers()
  
}
