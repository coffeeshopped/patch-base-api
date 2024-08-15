
import PBAPI

extension PatchController.AttrChange: JsParsable, JsArrayParsable {
  
  static let jsParsers: JsParseTransformSet<Self> = try! .init([
    (["dimItem"], {
      .dimItem(try $0.bool(1), try $0.path(2), dimAlpha: try? $0.cgFloat(3))
    }),
    (["setCtrlLabel", ".p", ".s"], {
      .setCtrlLabel(try $0.path(1), try $0.str(2))
    }),
    (["configCtrl", ".p", ".x"], {
      .configCtrl(try $0.path(1), .span(try $0.xform(2)))
    }),
  ], "PatchController.AttrChange")

  // allow for a single AttrChange in places where an array is returned
  static let jsArrayParsers: JsParseTransformSet<[Self]> = try! .init([
    ([".s"], { [try $0.xform()] }),
    (".a", {
      try $0.map { try $0.xform() }
    }),
  ], "PatchController.AttrChange array")
}
