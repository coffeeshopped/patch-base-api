
import PBAPI

extension PatchController: JsParsable {
  
  static let jsParsers: JsParseTransformSet<Self> = try! .init([
    ([
      "builders" : ".a",
    ], {
      let color: Int? = nil
      let border: Int? = nil
      var effects: [PatchController.Effect] = []
      if let fx = try? $0.any("effects") {
        effects = try fx.xform()
      }
      
      let layout: [PatchController.Constraint]? = try (try? $0.any("layout"))?.xform()
      
      return .patch(prefix: try? $0.xform("prefix"), color: color, border: border, try $0.xform("builders"), effects: effects, layout: layout ?? [])
    }),
    (["fm", ".a", ".f", ".d"], {
      let opFn = try $0.fn(2)
      let opCtrlr: (Int) throws -> PatchController = {
        try opFn.call([$0]).xform()
      }
      let config = try? $0.obj(3)
      let algoPath: SynthPath = (try? config?.path("algo")) ?? [.algo]
      let reverse = (try? config?.bool("reverse")) ?? false
      let selectable = (try? config?.bool("selectable")) ?? false

      return .fm(try $0.xform(1), opCtrlr: opCtrlr, algoPath: algoPath, reverse: reverse, selectable: selectable)
    })
  ], "controller")
  

}
