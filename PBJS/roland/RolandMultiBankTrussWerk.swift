//
//  RolandMultiBankTrussWerk.swift
//  PBJS
//
//  Created by Chadwick Wood on 9/18/24.
//

import PBAPI

extension RolandMultiBankTrussWerk: JsParsable {
  
  static let jsParsers: JsParseTransformSet<Self> = try! .init([
    ([
      "multiBank" : ".d",
      "patchCount" : ".n",
      "initFile" : ".s",
    ], {
      let addressCount = 3 // TODO: how to get this? It's in the sysexWerk
      let iso: RolandOffsetAddressIso = .init(address: {
        RolandAddress([$0, 0, 0])
      }, location: {
        $0.sysexBytes(count: addressCount)[1]
      })
      return try .init($0.x("multiBank"), $0.x("patchCount"), initFile: $0.x("initFile"), iso: iso, createFileFn: nil, validBundle: nil)
    }),
  ])
}

