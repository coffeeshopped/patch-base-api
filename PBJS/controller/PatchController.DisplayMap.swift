
import PBAPI

extension PatchController.DisplayMap: JsParsable, JsArrayParsable {
  
  static let jsParsers: JsParseTransformSet<Self> = try! .init([
    (["src", ".p", ".f"], {
      let fn = try $0.fn(2)
      return .src(try $0.x(1), dest: nil) {
        try fn.call([$0]).x()
      }
    }),
    (["u", ".p", ".n", ".p?"], {
      try .unit($0.x(1), dest: $0.xq(3), max: $0.x(2))
    }),
  ])

  static let jsArrayParsers = try! jsParsers.arrayParsers()
  
}
