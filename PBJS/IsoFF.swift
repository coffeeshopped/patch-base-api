
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
    })

  ]

}

extension IsoFF.SwitcherCheck: JsParsable {
  
  static let jsRules: [JsParseRule<Self>] = [
    .a([".n", ".n"], { try .int($0.x(0), $0.x(1)) }),
    .a([".a", ".n"], {
      let rngArr = try $0.arr(0)
      let min: Float = try rngArr.x(0)
      let max: Float = try rngArr.x(1) - 1
      return try .rangeString(min...max, $0.x(1))
    }),
    .a([".a", ".x"], {
      let rngArr = try $0.arr(0)
      let min: Float = try rngArr.x(0)
      let max: Float = try rngArr.x(1) - 1
      return try .range(min...max, $0.x(1))
    }),
  ]
}
