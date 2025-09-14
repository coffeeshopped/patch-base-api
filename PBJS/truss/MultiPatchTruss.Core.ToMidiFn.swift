//
//  MultiPatchTruss.Core.ToMidiFn.swift
//  PBJS
//
//  Created by Chadwick Wood on 8/21/24.
//

import PBAPI

extension SysexTrussCore<[SynthPath:[UInt8]]>.ToMidiFn {
  
  public static func jsName() -> String { "MultiPatchTruss.Core.ToMidiFn" }

  static let jsRules: [JsParseRule<Self>] = [
    .arr([SynthPath.self, SinglePatchTruss.Core.ToMidiFn.self], {
      // the first element of the array is a path to fetch subdata
      // the rest of the elements map make a SinglePatchTruss ToMidiFn
      let path: SynthPath = try $0.x(0)
      let singleToMidiFn: SinglePatchTruss.Core.ToMidiFn = try $0.x(1)
      return .fn { b, e in
        let sub = b[path] ?? [] // TODO: throw here?
        return try singleToMidiFn.call(sub, e)
      }
    }, "basic"),
    .t(UInt8.self, {
      // number: return it as a byte array
      return .msg([try $0.x()])
    }),
    .t([MultiPatchTruss.Core.ToMidiFn].self, { v in
      // implicit "+"
      let fns: [Self] = try v.map { try $0.x() }
      return .fn { b, e in try fns.flatMap { try $0.call(b, e) } }
    }),
    .t(JsFn.self, { fn in
      try fn.checkFn()
      let exportOrigin = fn.exportOrigin()
      return .fn { b, e in try fn.call([b, e], exportOrigin: exportOrigin).x() }
    }),
  ]
  
}
