
import PBAPI

extension PatchController.Display: JsParsable {
  
  public static let jsRules: [JsParseRule<Self>] = [
    .s("dadsrEnv", { _ in .dadsrEnv() }, "dadsrEnv"),
    .a("env", [JsFn.self], { try .env($0.fn(1)) }),
    .a("timeLevelEnv", [Int.self, Int.self], optional: [Bool.self], {
      try .timeLevelEnv(pointCount: $0.x(1), sustain: $0.x(2), bipolar: $0.xq(3))
    }),
    .s("levelScaling", { _ in .levelScaling() }),
  ]
  
}
