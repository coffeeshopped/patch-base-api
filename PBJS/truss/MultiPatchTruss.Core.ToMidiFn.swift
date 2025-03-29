//
//  MultiPatchTruss.Core.ToMidiFn.swift
//  PBJS
//
//  Created by Chadwick Wood on 8/21/24.
//

import PBAPI

extension SysexTrussCore<[SynthPath:[UInt8]]>.ToMidiFn {
  
  static var jsRules: [JsParseRule<Self>] = [
    .a(["+"], { v in
      let count = v.arrCount()
      let fns: [Self] = try (1..<count).map { try v.x($0) }
      return .fn { b, e in try fns.flatMap { try $0.call(b, e) } }
    }),
    .a([".p"], { v in
      // the first element of the array is a path to fetch subdata
      // the rest of the elements map [UInt8] -> [UInt8]
      let path: SynthPath = try v.x(0)
      let singleFns: [ByteTransform] = try (1..<v.arrCount()).map {
        try v.x($0)
      }

      return .fn { b, e in
        let sub = b[path] ?? []
        return try [.sysex(singleFns.reduce(sub) { partialResult, fn in try fn.call(partialResult, e) })]
      }
    }),
    .s(".n", {
      // number: return it as a byte array
      return .msg([try $0.x()])
    }),
    .s(".a", { v in
      // implicit "+" -- NOT ANYMORE
      // returns a function that returns an array of midi messages
      let fns: [Self] = try v.map { try $0.x() }
      return .fn { b, e in try fns.flatMap { try $0.call(b, e) } }
    }),
    .s(".f", { fn in
      try fn.checkFn()
      let exportOrigin = fn.exportOrigin()
      return .fn { b, e in try fn.call([b, e], exportOrigin: exportOrigin).x() }
    }),
  ]
  
  
}
