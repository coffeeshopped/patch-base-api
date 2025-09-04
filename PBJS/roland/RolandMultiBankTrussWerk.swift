
import PBAPI

extension RolandMultiBankTrussWerk: JsParsable {
  
  static let nuJsRules: [NuJsParseRule<Self>] = [
    .d([
      "multiBank" : RolandMultiPatchTrussWerk.self,
      "patchCount" : Int.self,
      "initFile" : String.self,
      "iso" : RolandOffsetAddressIso.self,
    ], {
      try .init($0.x("multiBank"), $0.x("patchCount"), initFile: $0.x("initFile"), iso: $0.x("iso"), createFileFn: nil, validBundle: nil)
    }),
  ]
  
  static let jsRules: [JsParseRule<Self>] = [
    .d([
      "multiBank" : ".d",
      "patchCount" : ".n",
      "initFile" : ".s",
      "iso" : ".x",
    ], {
      try .init($0.x("multiBank"), $0.x("patchCount"), initFile: $0.x("initFile"), iso: $0.x("iso"), createFileFn: nil, validBundle: nil)
    }),
  ]
}

