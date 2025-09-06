//
//  SomeBankTruss.swift
//  PBJS
//
//  Created by Chadwick Wood on 3/24/25.
//

import PBAPI

extension SomeBankTruss {

  static var nuBankToMidiRules: [JsParseRule<Core.ToMidiFn>] {
    [
      .d([
        "locationMap" : JsFn.self,
      ], {
        let locationMap = try $0.fn("locationMap")
        let exportOrigin = $0.exportOrigin()
        let fn: Core.ToMidiFn =  createFileDataWithLocationMap { bodyData, location in
          let f: PT.Core.ToMidiFn = try locationMap.call([location], exportOrigin: exportOrigin).x()
          return try f.call(bodyData, nil)
        }
        return fn
      }),
    ]
  }

}
