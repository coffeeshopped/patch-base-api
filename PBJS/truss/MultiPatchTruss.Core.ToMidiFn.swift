//
//  MultiPatchTruss.Core.ToMidiFn.swift
//  PBJS
//
//  Created by Chadwick Wood on 8/21/24.
//

import PBAPI

extension SysexTrussCore<[SynthPath:[UInt8]]>.ToMidiFn {
  
  static var jsParsers: JsParseTransformSet<Self> = try! .init([
    (["+"], { v in
      let count = v.arrCount()
      let fns: [Self] = try (1..<count).map { try v.x($0) }
      return .fn { b, e in try fns.reduce([]) { try $0 + $1.call(b, e) } }
    }),
    ([".p"], { v in
      // the first element of the array is a path to fetch subdata
      // the rest of the elements map [UInt8] -> [UInt8]
      let path: SynthPath = try v.x(0)
      let singleFns: [SinglePatchTruss.Core.ToMidiFn] = try (1..<v.arrCount()).map {
        try v.x($0)
      }

      return .fn { b, e in
        let sub = b[path] ?? []
        return try singleFns.reduce(sub) { partialResult, fn in try fn.call(partialResult, e) }
      }
    }),
    (".n", {
      // number: return it as a byte array
      return .const([try $0.x()])
    }),
    (".a", { v in
      // implicit "+"
      let fns: [Self] = try v.map { try $0.x() }
      return .fn { b, e in try fns.reduce([]) { try $0 + $1.call(b, e) } }
    }),
    (".f", { fn in
      try fn.checkFn()
      return .fn { b, e in try fn.call([b, e]).arrByte() }
    }),
  ], "multiPatchTruss toMidiRules")
  
  
}
