//
//  AnyRolandSysexTrussWerk.swift
//  PBJS
//
//  Created by Chadwick Wood on 9/16/24.
//

import PBAPI

extension JsParseTransformSet where Output: AnyRolandSysexTrussWerk {
  func anyWerkRules() -> [JsParseTransform<AnyRolandSysexTrussWerk>] {
    rules.map { r in .init(r.match, { try r.xform($0) as AnyRolandSysexTrussWerk }, "any werk")}
  }
}

let RolandSysexTrussWerkRules: JsParseTransformSet<AnyRolandSysexTrussWerk> = .init([
  RolandSinglePatchTrussWerk.jsParsers.anyWerkRules(),
].flatMap({ $0 }), "werk")
