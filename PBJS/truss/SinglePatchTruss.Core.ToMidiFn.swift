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
        try fns.flatMap { try $0.call(b, e) }
      }
    }),
    ([">"], { v in
      // treat as an array of functions, with the output of each function being fed as input to the next function (chaining).
      let fns: [Self] = try (1..<v.arrCount()).map { try v.x($0) }
      return .fn { b, e in
        try fns.reduce(b) { partialResult, fn in try fn.call(partialResult, e) }
      }
    }),
    (["e.values", ".p", ".a", ".f"], {
      let editorPath: SynthPath = try $0.x(1)
      let paths: [SynthPath] = try $0.arrPath(2)
      let fn = try $0.fn(3)
      let evts: [EditorValueTransform] = paths.map { .value(editorPath, $0, defaultValue: 0) }
      return .fn { bodyData, e in
        try evts.map {
          let v = try e?.intValue($0) ?? 0
          return try fn.call([v]).x()
        }
      }
    }),
    (["byte", ".n"], {
      let byte: Int = try $0.x(1)
      return .b { b in
        guard byte < b.count else {
          throw JSError.error(msg: "byte: index (\(byte)) must be less than data length (\(b.count)")
        }
        return [b[byte]]
      }
    }),
    (["enc", ".s"], {
      .const((try $0.x(1) as String).sysexBytes())
    }),
    (["yamCmd", ".x"], {
      let cmdBytes: Self = try $0.x(1)
      // second arg is optional, defaults to "b"
      let bodyData: Self? = try $0.xq(2)
      return .fn { b, e in try Yamaha.sysexData(cmdBytesWithChannel: cmdBytes.call(b, e), bodyBytes: bodyData?.call(b ,e) ?? b) }
    }),
    (["yamFetch", ".x"], {
      let chan: Self = try $0.x(1)
      // second arg is optional, defaults to "b"
      let cmdBytes: Self? = try $0.xq(2)
      return .fn { b, e in
        try Yamaha.fetchRequestBytes(channel: Int(chan.call(b, e).first ?? 0), cmdBytes: cmdBytes?.call(b ,e) ?? b)
      }
    }),
    (["yamParm", ".x"], {
      let chan: Self = try $0.x(1)
      // second arg is optional, defaults to "b"
      let cmdBytes: Self? = try $0.xq(2)
      return .fn { b, e in
        try Yamaha.paramData(channel: Int(chan.call(b, e).first ?? 0), cmdBytes: cmdBytes?.call(b ,e) ?? b)
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
        return .b(fn)
      }
      let bb: Self = try arg.x()
      return .fn { b, e in fn(try bb.call(b, e)) }
    }),
    (".a", { v in
      // if array, first see if it's an editorValueTransform
      if let fn = tryAsEditorValueTransform(v) {
        return fn
      }

      // otherwise, treat as an implicit "+"
      let fns: [Self] = try v.map { try $0.x() }
      return .fn { b, e in try fns.flatMap { try $0.call(b, e) } }
    }),
    (".f", { fn in
      try fn.checkFn()
      return .fn { b, e in try fn.call([b, e]).arrByte() }
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
    return .e { [try $0?.byteValue(evt) ?? 0] }
  }

}
