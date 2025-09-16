
import PBAPI

extension ByteTransform: JsParsable {
  
  public static let jsRules: [JsParseRule<Self>] = [
    .a(">", [ByteTransform.self], { v in
      // treat as an array of functions, with the output of each function being fed as input to the next function (chaining).
      let fns: [Self] = try (1..<v.arrCount()).map { try v.x($0) }
      return .fn { b, e in
        try fns.reduce(b) { partialResult, fn in try fn.call(partialResult, e) }
      }
    }),
    .s("b", { _ in .ident }), // returns itself
    .t(UInt8.self, { .const([try $0.x()]) }), // number: return it as a byte array
    .a("e.values", [SynthPath.self, [SynthPath].self, JsFn.self], {
      let editorPath: SynthPath = try $0.x(1)
      let paths: [SynthPath] = try $0.x(2)
      let fn = try $0.fn(3)
      let evts: [EditorValueTransform] = paths.map { .value(editorPath, $0, defaultValue: 0) }
      let exportOrigin = $0.exportOrigin()
      return .fn { bodyData, e in
        try evts.map {
          let v = try $0.intValue(e)
          return try fn.call([v], exportOrigin: exportOrigin).x()
        }
      }
    }),
    .a("byte", [Int.self], {
      let byte: Int = try $0.x(1)
      return .b { b in
        guard byte < b.count else {
          throw JSError.error(msg: "byte: index (\(byte)) must be less than data length (\(b.count)")
        }
        return [b[byte]]
      }
    }),
    .a("bytes", [JsObj.self], {
      let d = try $0.obj(1)
      let start: Int = try d.x("start")
      if let count: Int = try d.xq("count") {
        return arg1(try $0.xq(2) ?? .ident) {
          $0.safeBytes(offset: start, count: count)
        }
      }
      else if let end: Int = try d.xq("end") {
        if end < 0 {
          return arg1(try $0.xq(2) ?? .ident) {
            let offsetEnd = $0.count - end
            guard offsetEnd >= start else { return [] }
            return $0.safeBytes(start..<offsetEnd)
          }
        }
        else if end <= start {
          throw JSError.error(msg: "'end' must be greater than 'start', or negative")
        }
        else {
          return arg1(try $0.xq(2) ?? .ident) {
            $0.safeBytes(start..<end)
          }
        }
      }
      throw JSError.error(msg: "No argument for end of byte range found.")
    }),
    .a("bits", [ClosedRange<Int>.self], {
      let bitRange: ClosedRange<Int> = try $0.x(1)
      // second arg is optional, defaults to "b"
      return .arg1(try $0.xq(2) ?? .ident) {
        [UInt8(($0.first ?? 0).bits(bitRange))]
      }
    }),
    .a("bit", [Int.self], {
      let bit: Int = try $0.x(1)
      // second arg is optional, defaults to "b"
      return .arg1(try $0.xq(2) ?? .ident) {
        [UInt8(($0.first ?? 0).bits(bit...bit))]
      }
    }),
    .a("msBytes7bit", [Int.self, Int.self], {
      let value: Int = try $0.x(1)
      return try .const(value.bytes7bit(count: $0.x(2)))
    }),
    .a("enc", [String.self], {
      .const((try $0.x(1) as String).sysexBytes())
    }),
    .s("count", { _ in
      .b { b in [UInt8(b.count)] }
    }),
    .a("countDecomp", [String.self, Int.self], {
      // TODO: specify possible encodings.
      let encoding: String = try $0.x(1)
      let byteCount: Int = try $0.x(2)
      return .b { $0.count.bytes7bit(count: byteCount) }
    }),
    .a("nibblizeLSB", [], optional: [ByteTransform.self], {
      .arg1(try $0.xq(1) ?? .ident) {
        $0.flatMap { [UInt8($0.bits(0...3)), UInt8($0.bits(4...7))] }
      }
    }),
    .s("denibblizeLSB", { _ in
      .b { bytes in
        (bytes.count / 2).map {
          UInt8(bytes[$0 * 2].bits(0...3) + (bytes[$0 * 2 + 1].bits(0...3) << 4))
        }
      }
    }),
    .a("checksum", [], optional: [ByteTransform.self], {
      .arg1(try $0.xq(1) ?? .ident) {
        [UInt8($0.map{ Int($0) }.reduce(0, +) & 0x7f)]
      }
    }),
    .a("yamChk", [], optional: [ByteTransform.self], {
      .arg1(try $0.xq(1) ?? .ident) {
        [Yamaha.checksum(bytes: $0)]
      }
    }),
    .a("trussTransform", [JsObj.self], {
      let obj = try $0.obj(1)
      let fromTruss: SinglePatchTruss = try obj.x("from")
      let toTruss: SinglePatchTruss = try obj.x("to")
      return try .arg1(try $0.xq(2) ?? .ident) {
        try toTruss.parse(otherData: $0, otherTruss: fromTruss)
      }
    }),
    .t(EditorValueTransform.self, {
      let evt: EditorValueTransform = try $0.x()
      return .e { [try evt.byteValue($0)] }
    }),
    .arr([ByteTransform.self], {
      let fns: [Self] = try $0.map { try $0.x() }
      return .fn { b, e in
        try fns.flatMap { try $0.call(b, e) }
      }
    }, "array"),
    .t(JsFn.self, { fn in
      let exportOrigin = fn.exportOrigin()
      return .b { b in try fn.call([b], exportOrigin: exportOrigin).x() }
    }),
  ]
  
  static func arg1(_ arg: Self, _ fn: @escaping ([UInt8]) -> [UInt8]) -> Self {
    return .fn { b, e in
      try fn(arg.call(b, e))
    }
  }

  static func arg1(_ arg: Self, _ fn: @escaping ([UInt8]) throws -> [UInt8]) throws -> Self {
    return .fn { b, e in
      try fn(arg.call(b, e))
    }
  }

}
