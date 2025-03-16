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
  static var jsParsers: JsParseTransformSet<Self> {
    switch BodyData.self {
    case is [UInt8].Type:
      return SysexTrussCore<[UInt8]>.ToMidiFn.jsParsers as! JsParseTransformSet<Self>
    case is [SynthPath:[UInt8]].Type:
      return SysexTrussCore<[SynthPath:[UInt8]]>.ToMidiFn.jsParsers as! JsParseTransformSet<Self>
    default:
      fatalError("Unimplemented JsParsable")
    }
  }
  
}

extension SysexTrussCore<[UInt8]>.ToMidiFn {
  
  static let jsParsers: JsParseTransformSet<Self> = try! .init([
    (["+"], { v in
      let fns: [Self] = try (1..<v.arrCount()).map { try v.x($0) }
      return .fn { b, e in
        try .bytes(fns.flatMap { try $0.call(b, e).bytes() })
      }
    }),
    ([">"], { v in
      // treat as an array of functions, with the output of each function being fed as input to the next function (chaining).
      let fns: [Self] = try (1..<v.arrCount()).map { try v.x($0) }
      return .fn { b, e in
          .bytes(try fns.reduce(b) { partialResult, fn in try fn.call(partialResult, e).bytes() })
      }
    }),
    (["e.values", ".p", ".a", ".f"], {
      let editorPath: SynthPath = try $0.x(1)
      let paths: [SynthPath] = try $0.x(2)
      let fn = try $0.fn(3)
      let evts: [EditorValueTransform] = paths.map { .value(editorPath, $0, defaultValue: 0) }
      return .fn { bodyData, e in
        .bytes(try evts.map {
          let v = try e?.intValue($0) ?? 0
          return try fn.call([v]).x()
        })
      }
    }),
    (["byte", ".n"], {
      let byte: Int = try $0.x(1)
      return .b { b in
        guard byte < b.count else {
          throw JSError.error(msg: "byte: index (\(byte)) must be less than data length (\(b.count)")
        }
        return .bytes([b[byte]])
      }
    }),
    (["msBytes7bit", ".n", ".n"], {
      let value: Int = try $0.x(1)
      let byteCount: Int = try $0.x(2)
      return .const(value.bytes7bit(count: byteCount))
    }),
    (["enc", ".s"], {
      .const((try $0.x(1) as String).sysexBytes())
    }),
    (["yamCmd", ".x"], {
      let cmdBytes: Self = try $0.x(1)
      // second arg is optional, defaults to "b"
      let bodyData: Self? = try $0.xq(2)
      return .fn { b, e in try .msg(.sysex(Yamaha.sysexData(cmdBytesWithChannel: cmdBytes.call(b, e).bytes(), bodyBytes: bodyData?.call(b ,e).bytes() ?? b))) }
    }),
    (["yamFetch", ".x"], {
      let chan: Self = try $0.x(1)
      // second arg is optional, defaults to "b"
      let cmdBytes: Self? = try $0.xq(2)
      return .fn { b, e in
        try .msg(.sysex(Yamaha.fetchRequestBytes(channel: Int(chan.call(b, e).bytes().first ?? 0), cmdBytes: cmdBytes?.call(b ,e).bytes() ?? b)))
      }
    }),
    (["yamParm", ".x"], {
      let chan: Self = try $0.x(1)
      // second arg is optional, defaults to "b"
      let cmdBytes: Self? = try $0.xq(2)
      return .fn { b, e in
        try .msg(.sysex(Yamaha.paramData(channel: Int(chan.call(b, e).bytes().first ?? 0), cmdBytes: cmdBytes?.call(b ,e).bytes() ?? b)))
      }
    }),
    ("count", { _ in
      .b { b in .bytes([UInt8(b.count)]) }
    }),
    (["count", ".x", ".s", ".n"], {
      let bytes: Self = try $0.x(1)
      let encoding: String = try $0.x(2)
      let byteCount: Int = try $0.x(3)
      return .fn { b, e in
        let arr = try bytes.call(b, e).count.bytes7bit(count: byteCount)
        return .bytes(arr)
      }
    }),
    ("b", { _ in .ident }), // returns itself
    (".n", { .const([try $0.x()]) }), // number: return it as a byte array
    (".s", {
      // if string, first see if it's an editorValueTransform
      if let fn = tryAsEditorValueTransform($0) {
        return fn
      }

      // string: treat as singleArg fn
      let fnKey: String = try $0.x()
      guard let fn = singleArgCreateFileFnRules[fnKey] else {
        throw JSError.error(msg: "Unknown singleArgCreateFileFn: \(fnKey)")
      }
      
      guard let arg = try? $0.any(1) else {
        return .b({ .bytes(fn($0)) })
      }
      let bb: Self = try arg.x()
      return .fn { b, e in .bytes(fn(try bb.call(b, e).bytes())) }
    }),
    (".a", { v in
      // if array, first see if it's an editorValueTransform
      if let fn = tryAsEditorValueTransform(v) {
        return fn
      }

      // otherwise, treat as an implicit "+" -- NO MORE
      // now return a fn that returns an array of midimessages
      let fns: [Self] = try v.map { try $0.x() }
      return .fn { b, e in .arr(try fns.flatMap { try $0.call(b, e).midi() }) }
    }),
    (".f", { fn in
      return .fn { b, e in .bytes(try fn.call([b]).x()) }
    }),
  ], "singlePatchTruss createFile")
 
  static let singleArgCreateFileFnRules: [String:(BodyData) -> BodyData] = [
    "nibblizeLSB": {
      $0.flatMap { [UInt8($0.bits(0...3)), UInt8($0.bits(4...7))] }
    },
    "checksum": {
      [UInt8($0.map{ Int($0) }.reduce(0, +) & 0x7f)]
    },
  ]
  
  static func tryAsEditorValueTransform(_ value: JSValue) -> Self? {
    guard let evt: EditorValueTransform = try? value.x() else {
      return nil
    }
    return .e { .bytes([try $0?.byteValue(evt) ?? 0]) }
  }

}

