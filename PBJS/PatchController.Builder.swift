
import PBAPI

extension PatchController.Builder: JsParsable, JsArrayParsable {
  
  static let jsParsers: JsParseTransformSet<Self> = try! .init([
    (["child", ".x", ".s", ".d?"], {
      let child: PatchController = try $0.xform(1)
      let panel = try $0.str(2)
      let opts = try? $0.obj(3)
      let color = try? opts?.int("color")
      let clearBG = (try? opts?.bool("clearBG")) ?? false
      return .child(child, panel, color: color, clearBG: clearBG)
    }),
    (["panel", ".s", ".d", ".a"], {
      let opts = try? $0.obj(2)
      let color = try? opts?.int("color")
      let clearBG = (try? opts?.bool("clearBG")) ?? false
      let items = try $0.arr(3).xformArr(PatchController.PanelItem.rowRules)
      return .panel(try $0.str(1), prefix: [], color: color, clearBG: clearBG, items: items)
    }),
    (["grid", ".d", ".a"], {
      let opts = try? $0.obj(1)
      let color = try? opts?.int("color")
      let clearBG = (try? opts?.bool("clearBG")) ?? false
      let items: [[PatchController.PanelItem]] = try $0.arr(2).map { try $0.xform() }
      return .grid(prefix: nil, color: color, clearBG: clearBG, items)
    }),
    (["grid", ".a"], {
      let items: [[PatchController.PanelItem]] = try $0.arr(1).map { try $0.xform() }
      return .grid(prefix: nil, items)
    }),
  ], "builder")
  
  static let jsArrayParsers = try! jsParsers.arrayParsers()
}
