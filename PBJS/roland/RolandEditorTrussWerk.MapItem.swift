//
//  RolandEditorTrussWerk.MapItem.swift
//  PBJS
//
//  Created by Chadwick Wood on 9/16/24.
//

import PBAPI
import JavaScriptCore

extension RolandEditorTrussWerk.MapItem: JsParsable {
  
  static let nuJsRules: [NuJsParseRule<Self>] = [
    .arr([SynthPath.self, RolandAddress.self, JsObj.self], {
      try .init(path: $0.x(0), address: $0.x(1), werk: $0.any(2).xform(RolandSysexTrussWerkRules))
    }),
  ]
  
//  static let jsRules: [JsParseRule<Self>] = [
//    .s(".a", {
//      try .init(path: $0.x(0), address: $0.x(1), werk: $0.any(2).xform(RolandSysexTrussWerkRules))
//    }),
//  ]
  
}
