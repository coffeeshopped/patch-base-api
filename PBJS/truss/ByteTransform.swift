
import PBAPI

extension ByteTransform: JsParsable {
  
  static let jsRules: [JsParseRule<Self>] = [
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
          let v = try $0.intValue(e) ?? 0
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
    .a(["bits", ".a"], {
      let bitRange: ClosedRange<Int> = try $0.x(1)
      // second arg is optional, defaults to "b"
      let bodyData: Self = (try $0.xq(2)) ?? .ident
      return .fn { b, e in
        let bytes = try bodyData.call(b ,e)
        return [UInt8((bytes.first ?? 0).bits(bitRange))]
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
      let bytes: Self = try $0.x(1)
      let encoding: String = try $0.x(2)
      let byteCount: Int = try $0.x(3)
      return .fn { b, e in
        try bytes.call(b, e).count.bytes7bit(count: byteCount)
      }
    }),
    .s("nibblizeLSB", {
      let arg: Self = try $0.xq(1) ?? .ident
      return .fn { b, e in
        try arg.call(b, e).flatMap { [UInt8($0.bits(0...3)), UInt8($0.bits(4...7))] }
      }
    }),
    .s("checksum", { _ in
      .b { [UInt8($0.map{ Int($0) }.reduce(0, +) & 0x7f)] }
    }),
    .s(".s", {
      // if string, see if it's an editorValueTransform
      let evt: EditorValueTransform = try $0.x()
      return .e { [try evt.byteValue($0)] }
    }),
  ]
  
  
  
}
