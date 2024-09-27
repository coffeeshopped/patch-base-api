
import PBAPI

extension IsoFF : JsParsable {

  static let jsParsers: JsParseTransformSet<Self> = try! .init([
    (["+", ".n"], { try .a(Float($0.x(1) as Int)) })
  ])

}
