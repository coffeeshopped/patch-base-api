//
//  RolandAddress.swift
//  PBJS
//
//  Created by Chadwick Wood on 9/16/24.
//

import PBAPI
import JavaScriptCore

extension RolandAddress: JsParsable {
  
  static let jsRules: [JsParseRule<Self>] = [
    .t(Int.self, { RolandAddress(try $0.x() as Int) }),
    .t([UInt8].self, { RolandAddress(try $0.x() as [UInt8]) }),
  ]
  
}
