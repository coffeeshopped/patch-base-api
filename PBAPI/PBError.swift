//
//  PBError.swift
//  PBAPI
//
//  Created by Chadwick Wood on 8/15/24.
//


public enum PBError : Error {
  
  case error(_ msg: String)
  
  public func display() -> String {
    switch self {
    case .error(let msg):
      return msg
    }
  }

}
