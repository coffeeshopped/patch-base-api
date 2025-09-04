//
//  RolandMultiPatchTrussWerk.MapItem.swift
//  PBJS
//
//  Created by Chadwick Wood on 9/16/24.
//

import PBAPI

extension RolandMultiPatchTrussWerk.MapItem: JsParsable {
  
  static let nuJsRules: [NuJsParseRule<Self>] = [
    .arr([SynthPath.self, RolandAddress.self, RolandSinglePatchTrussWerk.self], {
      try .init(path: $0.x(0), address: $0.x(1), werk: $0.x(2))
    }),
  ]
  
  static let jsRules: [JsParseRule<Self>] = [
    .s(".a", {
      try .init(path: $0.x(0), address: $0.x(1), werk: $0.x(2))
    }),
  ]

}
