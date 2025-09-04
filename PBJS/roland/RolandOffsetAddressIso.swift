
import PBAPI

extension RolandOffsetAddressIso: JsParsable {
  
  static let nuJsRules: [NuJsParseRule<Self>] = [
    .a("lsbyte", [Int.self], optional: [UInt8.self], {
      try .lsByte($0.x(1), offset: $0.xq(2) ?? 0)
    }),
  ]
  
  static let jsRules: [JsParseRule<Self>] = [
    .a(["lsbyte", ".n", ".n?"], {
      try .lsByte($0.x(1), offset: $0.xq(2) ?? 0)
    }),
  ]
}
