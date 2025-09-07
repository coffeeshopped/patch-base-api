
import PBAPI

extension RolandMultiBankTrussWerk: JsParsable {
  
  public static let jsRules: [JsParseRule<Self>] = [
    .d([
      "multiBank" : RolandMultiPatchTrussWerk.self,
      "patchCount" : Int.self,
      "initFile" : String.self,
      "iso" : RolandOffsetAddressIso.self,
    ], {
      try .init($0.x("multiBank"), $0.x("patchCount"), initFile: $0.x("initFile"), iso: $0.x("iso"), createFileFn: nil, validBundle: nil)
    }, "rolandMultiBank"),
  ]
  
}

