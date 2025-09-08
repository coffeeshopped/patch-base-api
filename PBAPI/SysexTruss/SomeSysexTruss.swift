//
//  SomeSysexTruss.swift
//  PBAPI
//
//  Created by Chadwick Wood on 9/8/25.
//

import Foundation

public enum SomeSysexTruss {
  
  case single(SinglePatchTruss)
  case multi(MultiPatchTruss)
  case json(JSONPatchTruss)
  case singleBank(SingleBankTruss)
  case multiBank(MultiBankTruss)
  
}
