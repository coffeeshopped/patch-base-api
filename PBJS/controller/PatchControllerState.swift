//
//  PatchControllerState.swift
//  PBJS
//
//  Created by Chadwick Wood on 9/26/24.
//

import PBAPI

extension PatchControllerState : JsPassable {
  func toJS() -> AnyHashable {
    [
      "event" : event.toJS(),
      "index" : index,
      "prefix" : prefix?.toJS(),
      "params" : params.toJS(),
      "values" : values.toJS(),
      "names" : names.toJS(),
      "controls" : controls.toJS(),
    ]
  }
}
