//
//  DXAlgorithm.swift
//  PBJS
//
//  Created by Chadwick Wood on 8/15/24.
//

import PBAPI

extension DXAlgorithm : JsParsable {
  
  static let jsRules: [JsParseRule<Self>] = [
    .t([[String:[Int]]].self, {
      guard let arr = $0.toArray() as? [[String:[Int]]] else {
        throw JSError.error(msg: "DXAlgorithm: expected array of objects ([[String:[Int]]])")
      }
      return .init(arr)
    })
  ]
    
}
