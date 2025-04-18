//
//  RolandSinglePatchTrussWerk.swift
//  PBJS
//
//  Created by Chadwick Wood on 9/16/24.
//

import PBAPI

extension RolandSinglePatchTrussWerk: JsParsable {
  
  static let jsRules: [JsParseRule<Self>] = [
    .d([
      "single" : ".s",
      "parms" : ".x",
      "size" : ".n",
    ], {
      let parms: [Parm] = try $0.x("parms")
      return try .init($0.x("single"), parms.params(), size: $0.x("size"), name: $0.xq("name"), initFile: $0.xq("initFile") ?? "", defaultName: nil, randomize: nil)
    }),
  ]
}

