//
//  RolandEditorTrussWerk.MapItem.swift
//  PBJS
//
//  Created by Chadwick Wood on 9/16/24.
//

import PBAPI
import JavaScriptCore

extension RolandEditorTrussWerk.MapItem: JsParsable, JsArrayParsable {
  
  static let jsParsers: JsParseTransformSet<Self> = try! .init([
    (".a", {
      try .init(path: $0.x(0), address: $0.x(1), werk: $0.any(2).xform(RolandSysexTrussWerkRules))
    }),
  ])
  
  static let jsArrayParsers = try! jsParsers.arrayParsers()
}
