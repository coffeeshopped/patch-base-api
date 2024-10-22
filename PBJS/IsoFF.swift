
import PBAPI

extension IsoFF : JsParsable {

  static let jsParsers: JsParseTransformSet<Self> = try! .init([
    (["+", ".n"], { try .a($0.x(1)) }),
    (["-", ".n"], { try .a($0.x(1) * -1) }),
    (["*", ".n"], { try .m($0.x(1)) }),
    (["/", ".n"], { try .d($0.x(1)) }),
    (["switch", ".a", ".x?"], {
      try .switcher($0.x(1), default: $0.xq(2))
    }),
  ])

}

extension IsoFF.SwitcherCheck: JsArrayParsable {
  
  static let jsParsers: JsParseTransformSet<Self> = try! .init([
    ([".n", ".n"], { try .int($0.x(0), $0.x(1)) }),
    ([".a", ".n"], {
      let rngArr = try $0.arr(0)
      let min: Float = try rngArr.x(0)
      let max: Float = try rngArr.x(1) - 1
      return try .rangeString(min...max, $0.x(1))
    }),
    ([".a", ".x"], {
      let rngArr = try $0.arr(0)
      let min: Float = try rngArr.x(0)
      let max: Float = try rngArr.x(1) - 1
      return try .range(min...max, $0.x(1))
    }),
  ])
  
  static var jsArrayParsers = try! jsParsers.arrayParsers()
}
