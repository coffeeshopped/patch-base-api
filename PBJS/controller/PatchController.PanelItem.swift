
import PBAPI

extension PatchController.PanelItem: JsParsable, JsArrayParsable {
  
  static let jsParsers: JsParseTransformSet<Self> = try! .init([
    ([".s?", ".p"], { .knob(try? $0.str(0), try $0.path(1)) }),
    ([".d", ".p"], {
      let obj = try $0.obj(0)
      let path = try $0.path(1)
      let t = (try? obj.str("t")) ?? "knob"
      let l = try? obj.str("l")
      let id = try? obj.path("id")
      let w = try? obj.cgFloat("w")

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
      default:
        throw JSError.error(msg: "Unknown PanelItem type: \(t)")
      }
    }),
    ([
      "display" : ".s",
      "maps" : ".a",
    ], {
      let l = try? $0.str("l")
      let id = try? $0.path("id")
      let w = try? $0.cgFloat("w")
      return .display(try $0.xform("display"), l, try $0.xform("maps"), id: id, width: w)
    }),
    ("spacer", { _ in .spacer(2) }),
    ([
      "l" : ".s",
      "w" : ".n",
    ], {
      let l = try $0.str("l")
      let w = try $0.cgFloat("w")
      let id = try? $0.path("id")
      let bold = (try? $0.bool("bold")) ?? true
      let size = (try? $0.cgFloat("size")) ?? 13
      return .label(l, align: .center, size: size, bold: bold, id: id, width: w)
    })
  ], "panelItem")
  
  static let jsArrayParsers = try! jsParsers.arrayParsers()
  
  static let rowRules: JsParseTransformSet<([Self], CGFloat)> = try! .init([
    (".a", { (try $0.xform(), CGFloat(1)) }),
    ([
      "row": ".a",
      "h": ".n",
    ], { (try $0.xform("row"), try $0.cgFloat("h")) }),
  ], "panel row item")

}