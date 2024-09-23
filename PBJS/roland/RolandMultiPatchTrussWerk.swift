//
//  RolandMultiPatchTrussWerk.swift
//  PBJS
//
//  Created by Chadwick Wood on 9/16/24.
//

import PBAPI

extension RolandMultiPatchTrussWerk: JsParsable {
  
  static let jsParsers: JsParseTransformSet<Self> = try! .init([
    ([
      "multi" : ".s",
      "map" : ".x",
      "initFile" : ".s",
    ], {
      return try .init($0.x("multi"), $0.x("map"), initFile: $0.x("initFile"), sysexDataFn: nil, validBundle: nil)
    }),
  ])
}

