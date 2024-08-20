
import PBAPI

extension PatchController.PanelItem: JsParsable, JsArrayParsable {
  
  static let jsParsers: JsParseTransformSet<Self> = try! .init([
    ([".s?", ".p"], { .knob(try? $0.str(0), try $0.path(1)) }),
    ([".d", ".p?"], {
      let obj = try $0.obj(0)
      let path = try? $0.path(1)
      let t = (try? obj.str("t")) ?? "knob"
      let l = try? obj.str("l")
      let id = try? obj.path("id")
      let w = try? obj.cgFloat("w")
      let h = try? obj.cgFloat("h")
      
      switch t {
      case "knob":
        return .knob(l, path, id: nil, width: nil)
      case "switch", "switsch":
        return .switsch(l, path, id: id, width: w)
      case "checkbox":
        return .checkbox(l, path, id: id, width: w)
      case "spacer":
        return .spacer(try obj.cgFloat("w"))
      case "select":
        return .select(l, path, id: id, width: w)
      case "imgSelect":
        return .imgSelect(l, path, w: w!, h: h!, images: nil, spacing: nil, id: id, width: nil)
      default:
        throw JSError.error(msg: "Unknown PanelItem type: \(t)")
      }
    }),
    // maps: PatchController.Display
    ([
      "maps" : ".a",
    ], {
      let l = try? $0.str("l")
      let id = try? $0.path("id")
      let w = try? $0.cgFloat("w")
      return .display(try $0.xform(), l, try $0.xform("maps"), id: id, width: w)
    }),
    ("-", { _ in .spacer(2) }),
    ([
      "l" : ".s",
    ], {
      let l = try $0.str("l")
      let w = try? $0.cgFloat("w")
      let id = try? $0.path("id")
      let bold = (try? $0.bool("bold")) ?? true
      let size = (try? $0.cgFloat("size")) ?? 13
      return .label(l, align: .center, size: size, bold: bold, id: id, width: w)
    })
  ])
  
  static let jsArrayParsers = try! jsParsers.arrayParsers()
  
  static let rowRules: JsParseTransformSet<([Self], CGFloat)> = try! .init([
    (".a", { (try $0.xform(), CGFloat(1)) }),
    ([
      "row": ".a",
      "h": ".n",
    ], { (try $0.xform("row"), try $0.cgFloat("h")) }),
  ], "panel row item")

  static let itemsRules: JsParseTransformSet<(Self, String)> = try! .init([
    ([".d", ".s"], { (try $0.any(0).xform(), try $0.str(1)) }),
  ])

}
