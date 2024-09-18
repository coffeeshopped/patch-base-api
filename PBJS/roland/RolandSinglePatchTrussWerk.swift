//
//  RolandSinglePatchTrussWerk.swift
//  PBJS
//
//  Created by Chadwick Wood on 9/16/24.
//

import PBAPI

extension RolandSinglePatchTrussWerk: JsParsable {
  
  static let jsParsers: JsParseTransformSet<Self> = try! .init([
    ([
      "single" : ".s",
      "parms" : ".x",
      "size" : ".n",
      "start" : ".n",
    ], {
      let parms: [Parm] = try $0.x("parms")
      return try .init($0.x("single"), parms.params(), size: $0.x("size"), start: $0.x("start"), name: $0.xq("name"), initFile: $0.xq("initFile") ?? "", defaultName: nil, sysexDataFn: nil, randomize: nil)
    }),
  ])
}

