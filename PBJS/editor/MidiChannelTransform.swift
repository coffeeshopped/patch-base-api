
import PBAPI
import JavaScriptCore

extension MidiChannelTransform: JsParsable {
  
  static let jsParsers: JsParseTransformSet<Self> = try! .init([
    ("basic", { _ in .basic(map: nil) }),
    (["patch", ".p", ".p"], {
      try .patch($0.x(1), $0.x(2), map: nil)
    }),
  ])

  
}
