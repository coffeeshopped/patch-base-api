
import PBAPI

extension PatchController.AttrChange: JsParsable, JsArrayParsable {
  
  static let jsParsers: JsParseTransformSet<Self> = try! .init([
    (["dimItem"], {
      try .dimItem($0.x(1), $0.x(2), dimAlpha: $0.xq(3))
    }),
    (["hideItem"], {
      try .dimItem($0.x(1), $0.x(2), dimAlpha: 0)
    }),
    (["setCtrlLabel", ".p", ".s"], {
      try .setCtrlLabel($0.x(1), $0.x(2))
    }),
    (["configCtrl", ".p", ".x"], {
      try .configCtrl($0.x(1), .span($0.x(2)))
    }),
    (["dimPanel", ".b", ".s?", ".n?"], {
      try .dimPanel($0.x(1), $0.xq(2), dimAlpha: $0.xq(3))
    }),
    (["hidePanel", ".b", ".s?"], {
      try .dimPanel($0.x(1), $0.xq(2), dimAlpha: 0)
    }),
    (["setValue", ".p", ".n"], {
      try .setValue($0.x(1), $0.x(2))
    }),
    (["midiNote", ".d"], {
      let obj = try $0.obj(1)
      return try .midiNote(chan: obj.x("ch"), note: obj.x("n"), velo: obj.x("v"), len: obj.x("l"))
    }),
    (["colorItem", ".p", ".n?", ".b?"], {
      try .colorItem($0.x(1), level: $0.xq(2) ?? 1, clearBG: $0.xq(3))
    }),
  ], "PatchController.AttrChange")

  // allow for a single AttrChange in places where an array is returned
  static let jsArrayParsers: JsParseTransformSet<[Self]> = try! .init([
    ([".s"], { [try $0.x()] }),
    (".a", { try $0.map { try $0.x() } }),
  ], "PatchController.AttrChange array")
}
