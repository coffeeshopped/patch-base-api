
import PBAPI

extension PatchController.Display: JsParsable {
  
  static let jsParsers: JsParseTransformSet<Self> = try! .init([
    (["display" : "dadsrEnv"], { _ in .dadsrEnv() }),
    (["env" : ".f"], {
      let fn = try $0.fn("env")
      return .env { values in
        var v = [String:CGFloat]()
        values.forEach { v[$0.key.str()] = $0.value }
        return try fn.call([v]).x()
      }
    }),
    ([
      "display": "timeLevelEnv",
      "pointCount" : ".n",
      "sustain" : ".n",
      "bipolar" : ".b",
    ], {
      try .timeLevelEnv(pointCount: $0.x("pointCount"), sustain: $0.x("sustain"), bipolar: $0.x("bipolar"))
    }),
  ], "controller display")

}
