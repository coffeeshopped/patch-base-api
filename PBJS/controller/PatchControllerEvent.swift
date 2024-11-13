//
//  PatchControllerEvent.swift
//  PBJS
//
//  Created by Chadwick Wood on 11/13/24.
//

import PBAPI

extension PatchControllerEvent : JsPassable {
  
  func toJS() -> AnyHashable {
    switch self {
    case .initialize:
      return ["name" : "initialize"]
    case .nameChange(let path):
      return ["name" : "nameChange", 
              "path" : path.toJS()]
    case .paramsChange(let paths):
      return ["name" : "paramsChange", 
              "paths" : paths.map { $0.toJS() }] as Dictionary<String,AnyHashable>
    case .patchReplace:
      return ["name" : "patchReplace"]
    case .prefixChange:
      return ["name" : "prefixChange"]
    case .valuesChange(let paths):
      return ["name" : "valuesChange",
              "paths" : paths.map { $0.toJS() }] as Dictionary<String,AnyHashable>
    }
  }
  
  
}
