
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
  ], "controller")
  

}
