
import PBAPI

extension PatchController.DisplayMap: JsParsable {
  
  static let jsRules: [JsParseRule<Self>] = [
    .a(["src", ".p", ".f"], {
      return try .src($0.x(1), dest: nil, $0.fn(2))
    }),
    .a(["src", ".p", ".p", ".f?"], {
      if let fn = try? $0.fn(3) {
        return try .src($0.x(1), dest: $0.x(2), $0.fn(3))
      }
      else {
        return try .src($0.x(1), dest: $0.x(2)) { $0 }
      }
    }),
    .a(["u", ".p", ".n", ".p?"], {
      try .unit($0.x(1), dest: $0.xq(3), max: $0.x(2))
    }),
    .a(["u", ".p", ".p?"], {
      try .unit($0.x(1), dest: $0.xq(2))
    }),
    .a(["=", ".p", ".p?"], {
      try .ident($0.x(1), dest: $0.xq(2))
    }),
  ]
  
}
