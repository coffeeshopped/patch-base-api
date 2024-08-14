
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
      
      return .patch(prefix: try? $0.xform("prefix"), color: color, border: border, try $0.xform("builders"), effects: effects, layout: (try? $0.xform("layout")) ?? [])
    }),
    (["fm", ".a", ".f", ".d"], {
//      let algo = try $0.arr(1)
      let opFn = try $0.fn(2)
      let opCtrlr: (Int) -> PatchController = {
        try! opFn.call([$0]).xform()
      }
      let config = try? $0.obj(3)
      let algoPath: SynthPath = (try? config?.path("algo")) ?? [.algo]
      let reverse = (try? config?.bool("reverse")) ?? false
      let selectable = (try? config?.bool("selectable")) ?? false

      return .fm([], opCtrlr: opCtrlr, algoPath: algoPath, reverse: reverse, selectable: selectable)
    })
  ], "controller")
  

}
