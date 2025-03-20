
import PBAPI

extension MemSlot.Transform: JsParsable {
  
  static let jsRules: [JsParseRule<Self>] = [
    (["user", ".f"], {
      return try .user($0.fn(1))
    }),
    (["preset", ".f", ".a"], {
      return try .preset($0.fn(1), names: $0.x(2))
    }),
  ])

}
