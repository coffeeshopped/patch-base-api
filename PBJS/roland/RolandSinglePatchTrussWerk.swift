//
//  RolandSinglePatchTrussWerk.swift
//  PBJS
//
//  Created by Chadwick Wood on 9/16/24.
//

import PBAPI

extension RolandSinglePatchTrussWerk: JsParsable {
  
  static let nuJsRules: [NuJsParseRule<Self>] = [
    .d([
      "single" : String.self,
      "parms" : [Parm].self,
      "size" : RolandAddress.self,
      "name?" : String.self,
      "initFile?" : String.self,
    ], {
      let parms: [Parm] = try $0.x("parms")
      return try .init($0.x("single"), parms.params(), size: $0.x("size"), name: $0.xq("name"), initFile: $0.xq("initFile") ?? "", defaultName: nil, randomize: nil)
    }),
  ]
  
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

