
import PBAPI

extension PatchController.DisplayMap: JsParsable, JsArrayParsable {
  
  static let jsParsers: JsParseTransformSet<Self> = try! .init([
    (["src", ".p", ".f"], {
      let fn = try $0.fn(2)
      return .src(try $0.x(1), dest: nil) {
        try fn.call([$0]).x()
      }
    }),
    (["src", ".p", ".p", ".f?"], {
      if let fn = try? $0.fn(3) {
        return try .src($0.x(1), dest: $0.x(2)) {
          try fn.call([$0]).x()
        }
      }
      else {
        return try .src($0.x(1), dest: $0.x(2)) { $0 }
      }
    }),
    (["u", ".p", ".n", ".p?"], {
      try .unit($0.x(1), dest: $0.xq(3), max: $0.x(2))
    }),
    (["u", ".p", ".p?"], {
      try .unit($0.x(1), dest: $0.xq(2))
    }),
    (["=", ".p", ".p?"], {
      try .ident($0.x(1), dest: $0.xq(2))
    }),
  ])

  static let jsArrayParsers = try! jsParsers.arrayParsers()
  
}
