
import PBAPI

extension PatchController.Display: JsParsable {
  
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
