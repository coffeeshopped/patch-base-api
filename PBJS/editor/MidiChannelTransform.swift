
import PBAPI

extension MidiChannelTransform: JsParsable {
  
  static let jsParsers: JsParseTransformSet<Self> = try! .init([
    ("basic", { _ in .basic(map: nil) }),
    (["basic", ".f"], {
      try .basic(map: $0.fn(1))
    }),
    (["patch", ".p", ".p", ".f?"], {
      try .patch($0.x(1), $0.x(2), map: $0.fnq(3))
    }),
    (["custom", ".a", ".f"], {
      try .custom($0.x(1), $0.fn(2))
    }),
  ])

  
}
