
import PBAPI

extension RolandMultiBankTrussWerk: JsParsable {
  
  static let jsParsers: JsParseTransformSet<Self> = try! .init([
    ([
      "multiBank" : ".d",
      "patchCount" : ".n",
      "initFile" : ".s",
      "iso" : ".x",
    ], {
      try .init($0.x("multiBank"), $0.x("patchCount"), initFile: $0.x("initFile"), iso: $0.x("iso"), createFileFn: nil, validBundle: nil)
    }),
  ])
}

