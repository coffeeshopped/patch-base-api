
import PBAPI

extension PatchController: JsParsable {
  
  static let jsParsers: JsParseTransformSet<Self> = try! .init([
    ([
      "pages" : ".a",
      "builders" : ".a",
    ], {
      return try .paged(prefix: $0.xq("prefix"), color: nil, border: nil, $0.x("builders"), effects: $0.xq("effects") ?? [], layout: $0.xq("layout") ?? [], pages: $0.x("pages"))
    }),
    (["index", ".p", ".p", ".f", ".d"], {
      let fn = try $0.fn(3)
      let obj = try $0.obj(4)
      return try .index($0.x(1), label: $0.x(2), { try fn.call([$0]).toString() }, color: obj.xq("color"), border: obj.xq("border"), obj.x("builders"), effects: obj.xq("effects") ?? [], layout: obj.xq("layout") ?? [])
    }),
    (["palettes", ".d", ".n", ".p", ".s", ".s"], {
      try .palettes($0.x(1), $0.x(2), $0.x(3), $0.x(4), pasteType: $0.x(5), effects: [])
    }),
    ([
      "builders" : ".a",
      "gridLayout": ".a",
    ], {
      try .patch(prefix: $0.xq("prefix"), color: $0.xq("color"), border: $0.xq("border"), $0.x("builders"), effects: $0.xq("effects") ?? [], layout: [.grid($0.arr("gridLayout").xformArr(Constraint.gridRowRules))])
    }),
    ([
      "builders" : ".a",
      "simpleGridLayout": ".a",
    ], {
      try .patch(prefix: $0.xq("prefix"), color: $0.xq("color"), border: $0.xq("border"), $0.x("builders"), effects: $0.xq("effects") ?? [], layout: [.simpleGrid(try $0.x("simpleGridLayout"))])
    }),
    ([
      "builders" : ".a",
    ], {
      try .patch(prefix: $0.xq("prefix"), color: $0.xq("color"), border: $0.xq("border"), try $0.x("builders"), effects: $0.xq("effects") ?? [], layout: $0.xq("layout") ?? [])
    }),
    (["fm", ".a", ".x", ".d"], {
      let config = try? $0.obj(3)
      let algoPath: SynthPath? = try config?.xq("algo")
      let reverse: Bool? = try config?.xq("reverse")
      let selectable: Bool? = try config?.xq("selectable")
      if $0.atIndex(2).isFn {
        return try .fm($0.x(1), opCtrlr: $0.fn(2), algoPath: algoPath, reverse: reverse, selectable: selectable)
      }
      else {
        return try .fm($0.x(1), $0.x(2), algoPath: algoPath, reverse: reverse, selectable: selectable)
      }
    }),
    (["oneRow", ".n", ".d", ".f?"], {
      var f: ((Int,Int) throws -> Int)? = nil
      if let fn = try? $0.fn(3) {
        f = { try fn.call([$0, $1]).x() }
      }
      return .oneRow(try $0.x(1), child: try $0.x(2), indexMap: f)
    }),
  ])
  

}
