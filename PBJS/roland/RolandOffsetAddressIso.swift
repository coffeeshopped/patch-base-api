
import PBAPI

extension RolandOffsetAddressIso: JsParsable {
  
  static let jsParsers: JsParseTransformSet<Self> = try! .init([
    (["lsbyte", ".n", ".n?"], {
      try .lsByte($0.x(1), offset: $0.xq(2) ?? 0)
    }),
  ])
}
