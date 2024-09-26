//
//  PatchControllerState.swift
//  PBJS
//
//  Created by Chadwick Wood on 9/26/24.
//

import PBAPI

extension PatchControllerState {
  func toJS() -> [String:Any?] {
    [
      "event" : event,
      "index" : index,
      "prefix" : prefix?.toJS(),
      "params" : params.toJS(),
      "values" : values.toJS(),
      "names" : names.toJS(),
      "controls" : controls.toJS(),
    ]
  }
}
