
import PBAPI

extension PatchController.Builder: JsParsable {
  
  public static let jsRules: [JsParseRule<Self>] = [
    .d([
      "child" : PatchController.self,
      "id" : String.self,
      "color?" : Int.self,
      "clearBG?" : Bool.self,
    ], {
      try .child($0.x("child"), $0.x("id"), color: $0.xq("color"), clearBG: $0.xq("clearBG"))
    }, "childObj"),
    .a("child", [PatchController.self, String.self], {
      try .child($0.x(1), $0.x(2), color: nil, clearBG: nil)
    }),
    .d([
      "children" : PatchController.self,
      "id" : String.self,
      "count" : Int.self,
      "color?" : Int.self,
      "clearBG?" : Bool.self,
      "index?" : JsFn.self,
    ], {
      try .children($0.x("count"), $0.x("id"), color: $0.xq("color"), clearBG: $0.xq("clearBG"), $0.x("children"), indexFn: $0.fnq("index"))
    }, "childrenObj"),
    .a("children", [Int.self, String.self, PatchController.self], optional: [JsFn.self], {
      try .children($0.x(1), $0.x(2), color: nil, clearBG: nil, $0.x(3), indexFn: $0.fnq(4))
    }),
    .d([
      "panel" : String.self,
      "rows?" : [Row].self,
      "prefix?" : SynthPath.self,
      "color?" : Int.self,
      "clearBG?" : Bool.self,
    ], {
      let prefix: SynthPath = (try $0.xq("prefix")) ?? []
      return try .panel($0.x("panel"), prefix: prefix, color: $0.xq("color"), clearBG: $0.xq("clearBG"), rows: $0.xq("rows") ?? [])
    }, "panelObj"),
    .a("panel", [String.self], optional: [[Row].self], {
      try .panel($0.x(1), prefix: [], color: nil, clearBG: nil, rows: $0.xq(2) ?? [])
    }),
    .d([
      "grid" : [[PatchController.PanelItem]].self,
      "color?" : Int.self,
      "clearBG?" : Bool.self,
    ], {
      try .grid(prefix: nil, color: $0.xq("color"), clearBG: $0.xq("clearBG"), $0.x("grid"))
    }, "gridObj"),
    .a("grid", [[[PatchController.PanelItem]].self], {
      try .grid(prefix: nil, $0.x(1))
    }),
    .d([
      "items": [Row].self,
      "color?" : Int.self,
      "clearBG?" : Bool.self,
    ], {
      try .items(color: $0.xq("color"), clearBG: $0.xq("clearBG"), $0.x("items"))
    }, "itemsObj"),
    .a("items", [[Row].self], {
      try .items(color: nil, clearBG: nil, $0.x(1))
    }),
    .d([
      "switcher": [String].self,
      "l?" : String.self,
      "cols?" : Int.self,
      "color?" : Int.self,
    ], {
      try .switcher(label: $0.xq("l"), $0.x("switcher"), cols: $0.xq("cols"), color: $0.xq("color"))
    }, "switcherObj"),
    .a("switcher", [[String].self], optional: [String.self], {
      try .switcher(label: $0.xq(2), $0.x(1), cols: nil, color: nil)
    }),
    .a("button", [String.self, Int.self], {
      try .button($0.x(1), color: $0.xq(2))
    }),
    .a("nav", [String.self, SynthPath.self], optional: [Int.self], {
      try .nav($0.x(1), $0.x(2), color: $0.xq(3))
    }),
  ]

}

extension PatchController.Builder.Row : JsParsable {
  
  public static let jsRules: [JsParseRule<Self>] = [
    .t([PatchController.PanelItem].self, { try .init($0.x(), 1) }, "single"),
    .d([
      "row": [PatchController.PanelItem].self,
      "h": CGFloat.self,
    ], { try .init($0.x("row"), $0.x("h")) }, "withHeight"),
  ]

}

extension PatchController.Builder.ItemWithId : JsParsable {
  
  public static let jsRules: [JsParseRule<Self>] = [
    .arr([PatchController.PanelItem.self, String.self], { try .init($0.x(0), $0.x(1)) }, "basic"),
  ]
  
}
