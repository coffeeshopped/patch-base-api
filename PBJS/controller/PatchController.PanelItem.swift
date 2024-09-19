
import PBAPI

extension PatchController.PanelItem: JsParsable, JsArrayParsable {
  
  static let jsParsers: JsParseTransformSet<Self> = try! .init([
    (["switcher", ".a", ".d?"], {
      let c = try? $0.obj(2)
      return try .switcher(label: c?.xq("l"), $0.x(1), id: c?.xq("id"), width: c?.xq("w"), cols: c?.xq("cols"))
    }),
    ([".s?", ".p"], { .knob(try $0.xq(0), try $0.x(1)) }),
    ([".d", ".p?"], {
      let obj = try $0.obj(0)
      let path: SynthPath? = try $0.xq(1)
      var t: String = (try obj.xq("t")) ?? "knob"
      var l: String? = try obj.xq("l")
      let id: SynthPath? = try obj.xq("id")
      let w: CGFloat? = try obj.xq("w")
      let h: CGFloat? = try obj.xq("h")
      
      let ctrls = ["knob", "switch", "switsch", "checkbox", "select", "imgSelect"]
      try ctrls.forEach {
        guard let label: String = try obj.xq($0) else { return }
        t = $0
        l = label
      }
      
      switch t {
      case "knob":
        return .knob(l, path, id: nil, width: nil)
      case "switch", "switsch":
        return .switsch(l, path, id: id, width: w)
      case "checkbox":
        return .checkbox(l, path, id: id, width: w)
      case "spacer":
        return .spacer(try obj.x("w"))
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
      return try .display($0.x(), $0.xq("l"), $0.x("maps"), id: $0.xq("id"), width: $0.xq("w"))
    }),
    ("-", { _ in .spacer(2) }),
    ([
      "l" : ".s",
    ], {
      let bold = (try $0.xq("bold")) ?? true
      return try .label($0.x("l"), align: .center, size: $0.xq("size") ?? 13, bold: bold, id: $0.xq("id"), width: $0.xq("w"))
    })
  ])
  
  static let jsArrayParsers = try! jsParsers.arrayParsers()
  
  static let rowRules: JsParseTransformSet<([Self], CGFloat)> = try! .init([
    (".a", { (try $0.x(), CGFloat(1)) }),
    ([
      "row": ".a",
      "h": ".n",
    ], { (try $0.x("row"), try $0.x("h")) }),
  ], "panel row item")

  static let itemsRules: JsParseTransformSet<(Self, String)> = try! .init([
    ([".d", ".s"], { (try $0.any(0).x(), try $0.x(1)) }),
  ])

}
