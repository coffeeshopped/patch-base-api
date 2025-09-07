//
//  AnyRolandSysexTrussWerk.swift
//  PBJS
//
//  Created by Chadwick Wood on 9/16/24.
//

import PBAPI

extension JsParseRule where Output: AnyRolandSysexTrussWerk {
  func anyWerkRule() -> JsParseRule<AnyRolandSysexTrussWerk> {
    .init(match, { try transform($0) as AnyRolandSysexTrussWerk }, "anyWerk")
  }
}

let RolandSysexTrussWerkRules: [JsParseRule<AnyRolandSysexTrussWerk>] = [
  RolandSinglePatchTrussWerk.jsRules.map { $0.anyWerkRule()},
  RolandMultiPatchTrussWerk.jsRules.map { $0.anyWerkRule()},
  RolandMultiBankTrussWerk.jsRules.map { $0.anyWerkRule()},
].flatMap({ $0 })
