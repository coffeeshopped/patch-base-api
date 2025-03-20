
import PBAPI

extension RolandMultiPatchTrussWerk: JsParsable {
  
  static let jsRules: [JsParseRule<Self>] = [
    .d([
      "multi" : ".s",
      "map" : ".x",
      "initFile" : ".s",
    ], {
      return try .init($0.x("multi"), $0.x("map"), initFile: $0.x("initFile"), validBundle: nil)
    }),
  ]
}

