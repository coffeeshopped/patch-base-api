//
//  SomeSysexTruss.swift
//  PBJS
//
//  Created by Chadwick Wood on 9/9/25.
//

import Foundation
import PBAPI

extension SomeSysexTruss : JsParsable {
  
  public static var jsRules: [JsParseRule<Self>] = [
    .t(SinglePatchTruss.self, { try .single($0.x()) }),
    .t(MultiPatchTruss.self, { try .multi($0.x()) }),
    .t(JSONPatchTruss.self, { try .json($0.x()) }),
    .t(SingleBankTruss.self, { try .singleBank($0.x()) }),
    .t(MultiBankTruss.self, { try .multiBank($0.x()) }),
  ]
}
