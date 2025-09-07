
import PBAPI

extension PatchController.Display: JsParsable {
  
  public static let jsRules: [JsParseRule<Self>] = [
    .d(["dadsrEnv" : JsObj.self], { _ in .dadsrEnv() }, "dadsrEnv"),
    .d(["env" : JsFn.self], {
      try .env($0.fn("env"))
    }, "env"),
    .d([
      "timeLevelEnv": JsObj.self,
      "pointCount" : Int.self,
      "sustain" : Int.self,
      "bipolar?" : Bool.self,
    ], {
      try .timeLevelEnv(pointCount: $0.x("pointCount"), sustain: $0.x("sustain"), bipolar: $0.xq("bipolar"))
    }, "timeLevelEnv"),
    .d([
      "levelScaling" : JsObj.self,
    ], { _ in .levelScaling() }, "levelScaling"),
  ]
  
}
