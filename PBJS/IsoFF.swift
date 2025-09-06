
import PBAPI

extension IsoFF : JsParsable {

  public static let jsRules: [JsParseRule<Self>] = [
    .a("+", [Float.self], { try .a($0.x(1)) }),
    .a("-", [Float.self], { try .a($0.x(1) * -1) }),
    .a("*", [Float.self], { try .m($0.x(1)) }),
    .a("/", [Float.self], { try .d($0.x(1)) }),
    .a("!-", [Float.self], { try .m(-1) >>> .a($0.x(1)) }),
    .a("switch", [[SwitcherCheck].self], optional: [IsoFF.self], {
      try .switcher($0.x(1), default: $0.xq(2))
    }),
    .a("baseSwitch", [[SwitcherCheck].self], optional: [IsoFF.self], {
      try .switcher($0.x(1), default: $0.xq(2), withBase: true)
    }),
    .a("lerp", [ClosedRange<Float>.self, ClosedRange<Float>.self], {
      let inn: ClosedRange<Float> = try $0.x(1)
      return try .lerp(in: inn, out: $0.x(2))
    }),
    .s("round", .round()),
    .a("round", [Float.self], { try .round($0.x(1)) }),
    .s("=", .ident()),
  ]

}

extension IsoFF.SwitcherCheck: JsParsable {
  
  public static let jsRules: [JsParseRule<Self>] = [
    .arr([Int.self, Float.self], { try .int($0.x(0), $0.x(1)) }),
    .arr([ClosedRange<Float>.self, Float.self], { try .rangeString($0.x(0), $0.x(1)) }),
    .arr([ClosedRange<Float>.self, IsoFF.self], { try .range($0.x(0), $0.x(1)) }),
  ]
  
}
