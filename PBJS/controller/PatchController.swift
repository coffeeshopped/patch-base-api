
import PBAPI

extension PatchController: JsParsable {
  
  public static let jsRules: [JsParseRule<Self>] = [
    .d([
      "builders" : [Builder].self,
      "pages" : PageSetup.self,
      "gridLayout": [Constraint.Row].self,
      "prefix?" : Prefix.self,
      "effects?" : [Effect].self,
    ], {
      try .paged(prefix: $0.xq("prefix"), color: nil, border: nil, $0.x("builders"), effects: $0.xq("effects") ?? [], layout: [.grid($0.x("gridLayout"))], pages: $0.x("pages"))
    }),
    .d([
      "pages" : PageSetup.self,
      "builders" : [Builder].self,
      "prefix?" : Prefix.self,
      "effects?" : [Effect].self,
      "layout?" : [Constraint].self,
    ], {
      try .paged(prefix: $0.xq("prefix"), color: nil, border: nil, $0.x("builders"), effects: $0.xq("effects") ?? [], layout: $0.xq("layout") ?? [], pages: $0.x("pages"))
    }),
    .a("index", [SynthPath.self, SynthPath.self, JsFn.self, JsObj.self], {
      let obj = try $0.obj(4)
      return try .index($0.x(1), label: $0.x(2), $0.fn(3), color: obj.xq("color"), border: obj.xq("border"), obj.x("builders"), effects: obj.xq("effects") ?? [], layout: obj.xq("layout") ?? [])
    }),
    .a("palettes", [PatchController.self, Int.self, SynthPath.self, String.self, String.self], {
      try .palettes($0.x(1), $0.x(2), $0.x(3), $0.x(4), pasteType: $0.x(5), effects: [])
    }),
    .d([
      "builders" : [Builder].self,
      "prefix?" : Prefix.self,
      "color?" : Int.self,
      "border?" : Int.self,
      "effects?" : [Effect].self,
      "gridLayout": [Constraint.Row].self,
    ], {
      try .patch(prefix: $0.xq("prefix"), color: $0.xq("color"), border: $0.xq("border"), $0.x("builders"), effects: $0.xq("effects") ?? [], layout: [.grid($0.x("gridLayout"))])
    }),
    .d([
      "builders" : [Builder].self,
      "simpleGridLayout": [[Constraint.Item]].self,
      "prefix?" : Prefix.self,
      "color?" : Int.self,
      "border?" : Int.self,
      "effects?" : [Effect].self,
    ], {
      try .patch(prefix: $0.xq("prefix"), color: $0.xq("color"), border: $0.xq("border"), $0.x("builders"), effects: $0.xq("effects") ?? [], layout: [.simpleGrid(try $0.x("simpleGridLayout"))])
    }),
    .d([
      "gridBuilder" : [[PanelItem]].self,
      "prefix?" : Prefix.self,
      "color?" : Int.self,
      "border?" : Int.self,
      "effects?" : [Effect].self,
      "layout?" : [Constraint].self,
    ], {
      try .patch(prefix: $0.xq("prefix"), color: $0.xq("color"), border: $0.xq("border"), [.grid($0.x("gridBuilder"))], effects: $0.xq("effects") ?? [], layout: $0.xq("layout") ?? [])
    }),
    .d([
      "builders" : [Builder].self,
      "prefix?" : Prefix.self,
      "color?" : Int.self,
      "border?" : Int.self,
      "effects?" : [Effect].self,
      "layout?" : [Constraint].self,
    ], {
      try .patch(prefix: $0.xq("prefix"), color: $0.xq("color"), border: $0.xq("border"), $0.x("builders"), effects: $0.xq("effects") ?? [], layout: $0.xq("layout") ?? [])
    }),
    .a("fmFn", [[DXAlgorithm].self, JsFn.self, JsObj.self], {
      let config = try? $0.obj(3)
      let algoPath: SynthPath? = try config?.xq("algo")
      let reverse: Bool? = try config?.xq("reverse")
      let selectable: Bool? = try config?.xq("selectable")
      return try .fm($0.x(1), opCtrlr: $0.fn(2), algoPath: algoPath, reverse: reverse, selectable: selectable)
    }),
    .a("fm", [[DXAlgorithm].self, PatchController.self, JsObj.self], {
      let config = try? $0.obj(3)
      let algoPath: SynthPath? = try config?.xq("algo")
      let reverse: Bool? = try config?.xq("reverse")
      let selectable: Bool? = try config?.xq("selectable")
      return try .fm($0.x(1), $0.x(2), algoPath: algoPath, reverse: reverse, selectable: selectable)
    }),
    .a("oneRow", [Int.self, PatchController.self], optional: [JsFn.self], {
      return try .oneRow($0.x(1), child: $0.x(2), indexMap: $0.fnq(3))
    }),
  ]
  
}
