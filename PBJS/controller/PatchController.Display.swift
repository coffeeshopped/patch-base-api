
import PBAPI

extension PatchController.Display: JsParsable {
  
  static let nuJsRules: [NuJsParseRule<Self>] = [
    .d(["dadsrEnv" : JsObj.self], { _ in .dadsrEnv() }),
    .d(["env" : JsFn.self], {
      try .env($0.fn("env"))
    }),
    .d([
      "timeLevelEnv": JsObj.self,
      "pointCount" : Int.self,
      "sustain" : Int.self,
      "bipolar?" : Bool.self,
    ], {
      try .timeLevelEnv(pointCount: $0.x("pointCount"), sustain: $0.x("sustain"), bipolar: $0.xq("bipolar"))
    }),
    .d([
      "levelScaling" : JsObj.self,
    ], { _ in .levelScaling() }),
  ]
  
  static let jsRules: [JsParseRule<Self>] = [
    .d(["display" : "dadsrEnv"], { _ in .dadsrEnv() }),
    .d(["env" : ".f"], {
      try .env($0.fn("env"))
    }),
    .d([
      "display": "timeLevelEnv",
      "pointCount" : ".n",
      "sustain" : ".n",
      "bipolar" : ".b?",
    ], {
      try .timeLevelEnv(pointCount: $0.x("pointCount"), sustain: $0.x("sustain"), bipolar: $0.xq("bipolar"))
    }),
    .d([
      "display" : "levelScaling",
    ], { _ in .levelScaling() }),
  ]

}
