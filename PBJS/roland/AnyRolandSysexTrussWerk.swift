//
//  AnyRolandSysexTrussWerk.swift
//  PBJS
//
//  Created by Chadwick Wood on 9/16/24.
//

import PBAPI

extension NuJsParseRule where Output: AnyRolandSysexTrussWerk {
  func anyWerkRule() -> NuJsParseRule<AnyRolandSysexTrussWerk> {
    .init(match, { try transform($0) as AnyRolandSysexTrussWerk })
  }
}

let RolandSysexTrussWerkRules: [NuJsParseRule<AnyRolandSysexTrussWerk>] = [
  RolandSinglePatchTrussWerk.nuJsRules.map { $0.anyWerkRule()},
  RolandMultiPatchTrussWerk.nuJsRules.map { $0.anyWerkRule()},
  RolandMultiBankTrussWerk.nuJsRules.map { $0.anyWerkRule()},
].flatMap({ $0 })
