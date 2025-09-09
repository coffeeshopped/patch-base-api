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
  
  public func truss() -> any SysexTruss {
    switch self {
    case .single(let t):
      return t
    case .multi(let t):
      return t
    case .json(let t):
      return t
    case .singleBank(let t):
      return t
    case .multiBank(let t):
      return t
    }
  }
}
