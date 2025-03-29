//
//  SinglePatchTruss.Core.ToMidiFn.swift
//  PBJS
//
//  Created by Chadwick Wood on 8/21/24.
//

import PBAPI
import JavaScriptCore

extension SysexTrussCore.ToMidiFn : JsParsable {
  
  // this is gross, but the best I could come up with to overcome the "overlapping conformances" issue for now.
  // https://github.com/swiftlang/swift-evolution/blob/main/proposals/0143-conditional-conformances.md#overlapping-conformances
  static var jsRules: [JsParseRule<Self>] {
    switch BodyData.self {
    case is [UInt8].Type:
      return SysexTrussCore<[UInt8]>.ToMidiFn.jsRules as! [JsParseRule<Self>]
    case is [SynthPath:[UInt8]].Type:
      return SysexTrussCore<[SynthPath:[UInt8]]>.ToMidiFn.jsRules as! [JsParseRule<Self>]
    default:
      fatalError("Unimplemented JsParsable")
    }
  }
  
}

extension SysexTrussCore<[UInt8]>.ToMidiFn {
  
  static let jsRules: [JsParseRule<Self>] = [
    .a(["+"], { v in
      let fns: [Self] = try (1..<v.arrCount()).map { try v.x($0) }
      return .fn { b, e in
        try fns.flatMap { try $0.call(b, e) }
      }
    }),
    .a([">"], { v in
      // treat as an array of functions, with the output of each function being fed as input to the next function (chaining).
      let fns: [ByteTransform] = try (1..<v.arrCount()).map { try v.x($0) }
      return .fn { b, e in
        try [.sysex(fns.reduce(b) { partialResult, fn in try fn.call(partialResult, e) })]
      }
    }),
    .a(["yamCmd", ".x"], {
      let cmdBytes: ByteTransform = try $0.x(1)
      // second arg is optional, defaults to "b"
      let bodyData: ByteTransform = try $0.xq(2) ?? .ident
      return .fn { b, e in
        try [.sysex(Yamaha.sysexData(cmdBytesWithChannel: cmdBytes.call(b, e), bodyBytes: bodyData.call(b ,e)))]
      }
    }),
    .a(["yamFetch", ".x"], {
      let chan: ByteTransform = try $0.x(1)
      // second arg is optional, defaults to "b"
      let cmdBytes: ByteTransform = try $0.xq(2) ?? .ident
      return .fn { b, e in
        try [.sysex(Yamaha.fetchRequestBytes(channel: Int(chan.call(b, e).first ?? 0), cmdBytes: cmdBytes.call(b ,e)))]
      }
    }),
    .a(["yamParm", ".x"], {
      let chan: ByteTransform = try $0.x(1)
      // second arg is optional, defaults to "b"
      let cmdBytes: ByteTransform = try $0.xq(2) ?? .ident
      return .fn { b, e in
        try [.sysex(Yamaha.paramData(channel: Int(chan.call(b, e).first ?? 0), cmdBytes: cmdBytes.call(b ,e)))]
      }
    }),

    .s(".a", {
      // assume it's a byte transform
      let bt: ByteTransform = try $0.x()
      return .fn { b, e in
        try [.sysex(bt.call(b, e))]
      }
    }),
    .s(".f", { fn in
      let exportOrigin = fn.exportOrigin()
      return .b { b in try fn.call([b], exportOrigin: exportOrigin).x() }
    }),
  ]
   
}

