
import PBAPI

extension PatchController.Builder: JsParsable {
  
  static let jsRules: [JsParseRule<Self>] = [
    .a(["child", ".x", ".s", ".d?"], {
      let opts = try? $0.obj(3)
      return try .child($0.x(1), $0.x(2), color: opts?.xq("color"), clearBG: opts?.xq("clearBG"))
    }),
    .a(["children", ".n", ".s", ".d", ".d?"], {
      let opts = try? $0.obj(4)
      return try .children($0.x(1), $0.x(2), color: opts?.xq("color"), clearBG: opts?.xq("clearBG"), $0.x(3), indexFn: opts?.fnq("index"))
    }),
    .a(["panel", ".s", ".d", ".a"], {
      let opts = try? $0.obj(2)
      let items = try $0.arr(3).xformArr(PatchController.PanelItem.rowRules)
      let prefix: SynthPath = (try opts?.xq("prefix")) ?? []
      return try .panel($0.x(1), prefix: prefix, color: opts?.xq("color"), clearBG: opts?.xq("clearBG"), items: items)
    }),
    .a(["panel", ".s", ".a"], {
      let items = try $0.arr(2).xformArr(PatchController.PanelItem.rowRules)
      return try .panel($0.x(1), prefix: [], color: nil, clearBG: nil, items: items)
    }),
    .a(["grid", ".d", ".a"], {
      let opts = try? $0.obj(1)
      let items: [[PatchController.PanelItem]] = try $0.arr(2).map { try $0.x() }
      return try .grid(prefix: nil, color: opts?.xq("color"), clearBG: opts?.xq("clearBG"), items)
    }),
    .a(["grid", ".a"], {
      let items: [[PatchController.PanelItem]] = try $0.arr(1).map { try $0.x() }
      return .grid(prefix: nil, items)
    }),
    .a(["items", ".d", ".a"], {
      let opts = try? $0.obj(1)
      return try .items(color: opts?.xq("color"), clearBG: opts?.xq("clearBG"), $0.arr(2).xformArr(PatchController.PanelItem.itemsRules))
    }),
    .a(["switcher", ".a", ".d?"], {
      let c = try? $0.obj(2)
      return try .switcher(label: c?.xq("l"), $0.x(1), cols: c?.xq("cols"), color: c?.xq("color"))
    }),
    .a(["button", ".s", ".d?"], {
      let c = try? $0.obj(2)
      return try .button($0.x(1), color: c?.xq("color"))
    }),
    .a(["nav", ".s", ".p", ".d?"], {
      let c = try? $0.obj(3)
      return try .nav($0.x(1), $0.x(2), color: c?.xq("color"))
    }),
  ]
  
}
