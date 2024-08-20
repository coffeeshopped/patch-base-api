
import PBAPI

extension PatchController: JsParsable {
  
  static let jsParsers: JsParseTransformSet<Self> = try! .init([
    ([
      "builders" : ".a",
      "gridLayout": ".a",
    ], {
      let color: Int? = nil
      let border: Int? = nil
      var effects: [PatchController.Effect] = []
      if let fx = try? $0.any("effects") {
        effects = try fx.x()
      }
      
      let layout: PatchController.Constraint = .grid(try $0.arr("gridLayout").xformArr(PatchController.Constraint.gridRowRules))
      
      return .patch(prefix: try? $0.x("prefix"), color: color, border: border, try $0.x("builders"), effects: effects, layout: [layout])
    }),
    ([
      "builders" : ".a",
    ], {
      let color: Int? = nil
      let border: Int? = nil
      var effects: [PatchController.Effect] = []
      if let fx = try? $0.any("effects") {
        effects = try fx.x()
      }
      
      let layout: [PatchController.Constraint]? = try (try? $0.any("layout"))?.x()
      
      return .patch(prefix: try? $0.x("prefix"), color: color, border: border, try $0.x("builders"), effects: effects, layout: layout ?? [])
    }),
    (["fm", ".a", ".f", ".d"], {
      let opFn = try $0.fn(2)
      let opCtrlr: (Int) throws -> PatchController = {
        try opFn.call([$0]).x()
      }
      let config = try? $0.obj(3)
      let algoPath: SynthPath = (try config?.xq("algo")) ?? [.algo]
      let reverse = (try config?.xq("reverse")) ?? false
      let selectable = (try config?.xq("selectable")) ?? false

      return .fm(try $0.x(1), opCtrlr: opCtrlr, algoPath: algoPath, reverse: reverse, selectable: selectable)
    }),
    (["oneRow", ".n", ".d"], {
      return .oneRow(try $0.x(1), child: try $0.x(2), indexMap: nil)
    }),
  ])
  

}
