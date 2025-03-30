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
    .a(["yamCmd", ".x"], {
      try .arg2($0.x(1), $0.xq(2) ?? .ident) {
        [.sysex(Yamaha.sysexData(cmdBytesWithChannel: $0, bodyBytes: $1))]
      }
    }),
    .a(["yamFetch", ".x"], {
      // second arg is optional, defaults to "b"
      try .arg2($0.x(1), $0.xq(2) ?? .ident) {
        [.sysex(Yamaha.fetchRequestBytes(channel: Int($0.first ?? 0), cmdBytes: $1))]
      }
    }),
    .a(["yamParm", ".x"], {
      // second arg is optional, defaults to "b"
      try .arg2($0.x(1), $0.xq(2) ?? .ident) {
        [.sysex(Yamaha.paramData(channel: Int($0.first ?? 0), cmdBytes: $1))]
      }
    }),
    .s(".s", {
      // assume it's a byte transform
      let bt: ByteTransform = try $0.x()
      return .fn { b, e in
        try [.sysex(bt.call(b, e))]
      }
    }),
    .s(".a", {
      // first see if it's a byte transform
      if let bt = try? $0.x() as ByteTransform {
        return .fn { b, e in
          try [.sysex(bt.call(b, e))]
        }
      }
      
      let fns: [Self] = try $0.map { try $0.x() }
      return .fn { b, e in
        try fns.flatMap { try $0.call(b, e) }
      }
    }),
//    .s(".f", { fn in
//      let exportOrigin = fn.exportOrigin()
//      return .b { b in try fn.call([b], exportOrigin: exportOrigin).x() }
//    }),
  ]
  
  static func arg2(_ arg1: ByteTransform, _ arg2: ByteTransform, _ fn: @escaping ([UInt8], [UInt8]) -> [MidiMessage]) -> Self {
    return .fn { b, e in
      try fn(arg1.call(b, e), arg2.call(b, e))
    }
  }

   
}

