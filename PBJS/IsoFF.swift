
import PBAPI

extension IsoFF : JsParsable {

  static let nuJsRules: [NuJsParseRule<Self>] = [
    .s("+ .n", { try .a($0.x(1)) }),
    .s("- .n", { try .a($0.x(1) * -1) }),
    .s("* .n", { try .m($0.x(1)) }),
    .s("/ .n", { try .d($0.x(1)) }),
    .s("!- .n", { try .m(-1) >>> .a($0.x(1)) }),
    .s("switch [SwitcherCheck] IsoFF?", {
      try .switcher($0.x(1), default: $0.xq(2))
    }),
    .s("baseSwitch [SwitcherCheck] IsoFF?", {
      try .switcher($0.x(1), default: $0.xq(2), withBase: true)
    }),
    .s("lerp Range Range", {
      let inn: ClosedRange<Float> = try $0.x(1)
      return try .lerp(in: inn, out: $0.x(2))
    }),
    .s("round", .round()),
    .s("round .n", { try .round($0.x(1)) }),
    .s("=", .ident()),
  ]
  
  static let jsRules: [JsParseRule<Self>] = [
    .a(["+", ".n"], { try .a($0.x(1)) }),
    .a(["-", ".n"], { try .a($0.x(1) * -1) }),
    .a(["*", ".n"], { try .m($0.x(1)) }),
    .a(["/", ".n"], { try .d($0.x(1)) }),
    .a(["!-", ".n"], { try .m(-1) >>> .a($0.x(1)) }),
    .a(["switch", ".a", ".x?"], {
      try .switcher($0.x(1), default: $0.xq(2))
    }),
    .a(["baseSwitch", ".a", ".x?"], {
      try .switcher($0.x(1), default: $0.xq(2), withBase: true)
    }),
    .a(["lerp", ".a", ".a"], {
      let inn: ClosedRange<Float> = try $0.x(1)
      return try .lerp(in: inn, out: $0.x(2))
    }),
    .s("round", .round()),
    .a(["round", ".n"], { try .round($0.x(1)) }),
    .s("=", .ident()),
  ]

}

extension IsoFF.SwitcherCheck: JsParsable {
  
  static let jsRules: [JsParseRule<Self>] = [
    .a([".n", ".n"], { try .int($0.x(0), $0.x(1)) }),
    .a([".a", ".n"], { try .rangeString($0.x(0), $0.x(1)) }),
    .a([".a", ".x"], { try .range($0.x(0), $0.x(1)) }),
  ]
}
