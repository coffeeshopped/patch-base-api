
import PBAPI

extension MemSlot.Transform: JsParsable {
  
  public static let jsRules: [JsParseRule<Self>] = [
    .a("user", [JsFn.self], {
      try .user($0.fn(1))
    }),
    .a("preset", [JsFn.self, [String].self], {
      try .preset($0.fn(1), names: $0.x(2))
    }),
  ]

}
