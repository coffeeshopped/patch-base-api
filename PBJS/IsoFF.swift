
import PBAPI

extension IsoFF : JsParsable {

  static let jsRules: [JsParseRule<Self>] = [
    .a(["+", ".n"], { try .a($0.x(1)) }),
    .a(["-", ".n"], { try .a($0.x(1) * -1) }),
    .a(["*", ".n"], { try .m($0.x(1)) }),
    .a(["/", ".n"], { try .d($0.x(1)) }),
    .a(["switch", ".a", ".x?"], {
      try .switcher($0.x(1), default: $0.xq(2))
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
