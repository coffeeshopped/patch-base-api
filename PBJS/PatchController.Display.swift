
import PBAPI

extension PatchController.Display: JsParsable {
  
  static let jsParsers: JsParseTransformSet<Self> = try! .init([
    ("dadsrEnv", { _ in PatchController.Display.dadsrEnv() })
  ], "controller display")

}
