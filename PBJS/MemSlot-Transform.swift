
import PBAPI

extension MemSlot.Transform: JsParsable {
  
  static let jsParsers: JsParseTransformSet<Self> = try! .init([
    ([
      "user" : ".f",
    ], {
      let fn = try $0.fn("user")
      return .user({ try! fn.call([$0]).toString() })
    }),
  ], "slotTransform")

}
