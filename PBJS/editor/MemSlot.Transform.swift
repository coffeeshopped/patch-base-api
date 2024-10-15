
import PBAPI

extension MemSlot.Transform: JsParsable {
  
  static let jsParsers: JsParseTransformSet<Self> = try! .init([
    (["user", ".f"], {
      let fn = try $0.fn(1)
      return .user({ try fn.call([$0]).x() })
    }),
    (["preset", ".f", ".a"], {
      let fn = try $0.fn(1)
      return try .preset({ try fn.call([$0]).x() }, names: $0.x(2))
    }),
  ], "slotTransform")

}
