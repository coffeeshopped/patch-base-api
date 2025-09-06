
import PBAPI

extension RolandOffsetAddressIso: JsParsable {
  
  public static let jsRules: [JsParseRule<Self>] = [
    .a("lsbyte", [Int.self], optional: [UInt8.self], {
      try .lsByte($0.x(1), offset: $0.xq(2) ?? 0)
    }),
  ]
  
}
