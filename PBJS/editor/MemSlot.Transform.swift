
import PBAPI

extension MemSlot.Transform: JsParsable {
  
  static let jsRules: [JsParseRule<Self>] = [
    .a(["user", ".f"], {
      try .user($0.fn(1))
    }),
    .a(["preset", ".f", ".a"], {
      try .preset($0.fn(1), names: $0.x(2))
    }),
  ]

}
