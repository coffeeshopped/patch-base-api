
import PBAPI

extension MemSlot.Transform: JsParsable {
  
  static let nuJsRules: [NuJsParseRule<Self>] = [
    .a("user", [JsFn.self], {
      try .user($0.fn(1))
    }),
    .a("preset", [JsFn.self, [String].self], {
      try .preset($0.fn(1), names: $0.x(2))
    }),
  ]
  
  static let jsRules: [JsParseRule<Self>] = [
    .a(["user", ".f"], {
      try .user($0.fn(1))
    }),
    .a(["preset", ".f", ".a"], {
      try .preset($0.fn(1), names: $0.x(2))
    }),
  ]

}
