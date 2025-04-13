
import PBAPI

extension ByteTransform: JsParsable {
  
  static let jsRules: [JsParseRule<Self>] = [
    .a([">"], { v in
      // treat as an array of functions, with the output of each function being fed as input to the next function (chaining).
      let fns: [Self] = try (1..<v.arrCount()).map { try v.x($0) }
      return .fn { b, e in
        try fns.reduce(b) { partialResult, fn in try fn.call(partialResult, e) }
      }
    }),
    .s("b", { _ in .ident }), // returns itself
    .s(".n", { .const([try $0.x()]) }), // number: return it as a byte array
    .a(["e.values", ".p", ".a", ".f"], {
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
    .a(["byte", ".n"], {
      let byte: Int = try $0.x(1)
      return .b { b in
        guard byte < b.count else {
          throw JSError.error(msg: "byte: index (\(byte)) must be less than data length (\(b.count)")
        }
        return [b[byte]]
      }
    }),
    .a(["bytes", ".d"], {
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
            $0.safeBytes(start..<($0.count - end))
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
    .a(["bits", ".a"], {
      let bitRange: ClosedRange<Int> = try $0.x(1)
      // second arg is optional, defaults to "b"
      return .arg1(try $0.xq(2) ?? .ident) {
        [UInt8(($0.first ?? 0).bits(bitRange))]
      }
    }),
    .a(["bit", ".n"], {
      let bit: Int = try $0.x(1)
      // second arg is optional, defaults to "b"
      return .arg1(try $0.xq(2) ?? .ident) {
        [UInt8(($0.first ?? 0).bits(bit...bit))]
      }
    }),
    .a(["msBytes7bit", ".n", ".n"], {
      let value: Int = try $0.x(1)
      let byteCount: Int = try $0.x(2)
      return .const(value.bytes7bit(count: byteCount))
    }),
    .a(["enc", ".s"], {
      .const((try $0.x(1) as String).sysexBytes())
    }),
    .s("count", { _ in
      .b { b in [UInt8(b.count)] }
    }),
    .a(["count", ".x", ".s", ".n"], {
      let encoding: String = try $0.x(2)
      let byteCount: Int = try $0.x(3)
      return .arg1(try $0.x(1)) {
        $0.count.bytes7bit(count: byteCount)
      }
    }),
    .a(["nibblizeLSB", ".x?"], {
      .arg1(try $0.xq(1) ?? .ident) {
        $0.flatMap { [UInt8($0.bits(0...3)), UInt8($0.bits(4...7))] }
      }
    }),
    .a(["denibblizeLSB", ".x?"], {
      .arg1(try $0.xq(1) ?? .ident) { bytes in
        (bytes.count / 2).map {
          UInt8(bytes[$0 * 2].bits(0...3) + (bytes[$0 * 2 + 1].bits(0...3) << 4))
       }
      }
    }),
    .a(["checksum", ".x?"], {
      .arg1(try $0.xq(1) ?? .ident) {
        [UInt8($0.map{ Int($0) }.reduce(0, +) & 0x7f)]
      }
    }),
    .a(["yamChk", ".x?"], {
      .arg1(try $0.xq(1) ?? .ident) {
        [Yamaha.checksum(bytes: $0)]
      }
    }),
    .a(["trussTransform", ".d"], {
      let obj = try $0.obj(1)
      let fromTruss: SinglePatchTruss = try obj.x("from")
      let toTruss: SinglePatchTruss = try obj.x("to")
      return try .arg1(try $0.xq(2) ?? .ident) {
        try toTruss.parse(otherData: $0, otherTruss: fromTruss)
      }
    }),
    .s(".s", {
      // if string, see if it's an editorValueTransform
      let evt: EditorValueTransform = try $0.x()
      return .e { [try evt.byteValue($0)] }
    }),
    .s(".a", {
      // first see if it's an EVT
      if let evt = try? $0.x() as EditorValueTransform {
        return .e { [try evt.byteValue($0)] }
      }
      
      let fns: [Self] = try $0.map { try $0.x() }
      return .fn { b, e in
        try fns.flatMap { try $0.call(b, e) }
      }
    }),
    .s(".f", { fn in
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
