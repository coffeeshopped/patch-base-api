
import PBAPI

extension PatchController.PanelItem: JsParsable {
  
  static let jsRules: [JsParseRule<Self>] = [
    .a(["switcher", ".a", ".d?"], {
      let c = try? $0.obj(2)
      return try .switcher(label: c?.xq("l"), $0.x(1), id: c?.xq("id"), width: c?.xq("w"), cols: c?.xq("cols"))
    }),
    .a([".s?", ".p"], { try .knob($0.xq(0), $0.x(1)) }),
    .a([".d", ".p?"], {
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
        l = label == "." ? nil : label
      }
      
      switch t {
      case "knob":
        return .knob(l, path, id: id, width: nil)
      case "switch", "switsch":
        return .switsch(l, path, id: id, width: w)
      case "checkbox":
        return .checkbox(l, path, id: id, width: w)
      case "spacer":
        return .spacer(try obj.x("w"))
      case "select":
        return .select(l, path, id: id, width: w)
      case "imgSelect":
        let moduleBasePath = try JsModuleTruss.moduleBasePath($0)
        var images: [String]? = nil
        if let imgs = try obj.xq("images") as [String]? {
          images = imgs.map { "\(moduleBasePath)\($0)" }
        }
        return .imgSelect(l, path, w: w!, h: h!, images: images, spacing: nil, id: id, width: nil)
      default:
        throw JSError.error(msg: "Unknown PanelItem type: \(t)")
      }
    }),
    // maps: PatchController.Display
    .d([
      "maps" : ".a",
    ], {
      var maps: [PatchController.DisplayMap] = try $0.x("maps")
      if let srcPrefix = try? $0.x("srcPrefix") as SynthPath {
        maps = maps.map { $0.srcPrefix(srcPrefix) }
      }
      return try .display($0.x(), $0.xq("l"), maps, id: $0.xq("id"), width: $0.xq("w"))
    }),
    .s("-", { _ in .spacer(2) }),
    .d([
      "l" : ".s",
    ], {
      let bold = (try $0.xq("bold")) ?? true
      return try .label($0.x("l"), align: .center, size: $0.xq("size") ?? 13, bold: bold, id: $0.xq("id"), width: $0.xq("w"))
    }),
    .s(".p", {
      try .knob(nil, $0.x())
    })
  ]
    
  static let rowRules: [JsParseRule<([Self], CGFloat)>] = [
    .s(".a", { (try $0.x(), CGFloat(1)) }),
    .d([
      "row": ".a",
      "h": ".n",
    ], { (try $0.x("row"), try $0.x("h")) }),
  ]

  static let itemsRules: [JsParseRule<(Self, String)>] = [
    .a([".d", ".s"], { (try $0.any(0).x(), try $0.x(1)) }),
  ]

}
