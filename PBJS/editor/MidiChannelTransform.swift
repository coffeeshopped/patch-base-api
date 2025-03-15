
import PBAPI
import JavaScriptCore

extension MidiChannelTransform: JsParsable {
  
  static let jsParsers: JsParseTransformSet<Self> = try! .init([
    ("basic", { _ in .basic(map: nil) }),
    (["basic", ".f"], {
      return try .basic(map: $0.fn(1))
    }),
    (["patch", ".p", ".p", ".f?"], {
      var fn: MidiChannelTransform.MapFn? = nil
      if let f = try? $0.fn(3) {
        fn = { try f.call([$0]).x() }
      }
      return try .patch($0.x(1), $0.x(2), map: fn)
    }),
    (["custom", ".a", ".f"], {
      let f = try $0.fn(2)
      return try .custom($0.x(1), { try f.call([$0]).x() })
    }),
  ])

  
}
