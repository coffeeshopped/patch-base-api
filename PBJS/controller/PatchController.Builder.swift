
import PBAPI

extension PatchController.Builder: JsParsable {
  
  public static let jsRules: [JsParseRule<Self>] = [
    .a("child", [PatchController.self, String.self], optional: [JsObj.self], {
      let opts = try? $0.obj(3)
      return try .child($0.x("1"), $0.x(2), color: opts?.xq("color"), clearBG: opts?.xq("clearBG"))
    }),
    .a("children", [Int.self, String.self, PatchController.self], optional: [JsObj.self], {
      let opts = try? $0.obj(4)
      return try .children($0.x(1), $0.x(2), color: opts?.xq("color"), clearBG: opts?.xq("clearBG"), $0.x(3), indexFn: opts?.fnq("index"))
    }),
    .a("panel", [String.self, JsObj.self, [Row].self], {
      let opts = try? $0.obj(2)
      let prefix: SynthPath = (try opts?.xq("prefix")) ?? []
      return try .panel($0.x(1), prefix: prefix, color: opts?.xq("color"), clearBG: opts?.xq("clearBG"), rows: $0.x(3))
    }),
    .a("panel", [String.self, [Row].self], {
      try .panel($0.x(1), prefix: [], color: nil, clearBG: nil, rows: $0.x(2))
    }),
    .a("grid", [JsObj.self, [[PatchController.PanelItem]].self], {
      let opts = try? $0.obj(1)
      return try .grid(prefix: nil, color: opts?.xq("color"), clearBG: opts?.xq("clearBG"), $0.x(2))
    }),
    .a("grid", [[[PatchController.PanelItem]].self], {
      try .grid(prefix: nil, $0.x(1))
    }),
    .a("items", [JsObj.self, [Row].self], {
      let opts = try? $0.obj(1)
      return try .items(color: opts?.xq("color"), clearBG: opts?.xq("clearBG"), $0.x(2))
    }),
    .a("switcher", [[String].self], optional: [JsObj.self], {
      let c = try? $0.obj(2)
      return try .switcher(label: c?.xq("l"), $0.x(1), cols: c?.xq("cols"), color: c?.xq("color"))
    }),
    .a("button", [String.self, JsObj.self], {
      let c = try? $0.obj(2)
      return try .button($0.x(1), color: c?.xq("color"))
    }),
    .a("nav", [String.self, SynthPath.self], optional: [JsObj.self], {
      let c = try? $0.obj(3)
      return try .nav($0.x(1), $0.x(2), color: c?.xq("color"))
    }),
  ]

}

extension PatchController.Builder.Row : JsParsable {
  
  public static let jsRules: [JsParseRule<Self>] = [
    .arr([[PatchController.PanelItem].self], { try .init($0.x(), 1) }),
    .d([
      "row": [PatchController.PanelItem].self,
      "h": CGFloat.self,
    ], { try .init($0.x("row"), $0.x("h")) }),
  ]

}

extension PatchController.Builder.ItemWithId : JsParsable {
  
  public static let jsRules: [JsParseRule<Self>] = [
    .arr([PatchController.PanelItem.self, String.self], { try .init($0.x(0), $0.x(1)) }),
  ]
  
}
