//
//  RolandAddress.swift
//  PBJS
//
//  Created by Chadwick Wood on 9/16/24.
//

import PBAPI
import JavaScriptCore

extension RolandAddress: JsParsable {
  
  static let jsParsers: JsParseTransformSet<Self> = try! .init([
    (".n", { RolandAddress(try $0.x() as Int) }),
  ])
}
