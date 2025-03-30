
import PBAPI

extension MidiMessage: JsParsable {
  
  static let jsRules: [JsParseRule<Self>] = [
    .a([0xf0], { .sysex(try $0.x()) }),
    .a(["syx", ".a"], { .sysex(try $0.arr(1).x()) }),
    .a(["pgmChange", ".n", ".n"], { try .pgmChange(channel: $0.x(1), value: $0.x(2)) }),
  ]

  static let dynamicRules: [JsParseRule<(AnySynthEditor) throws -> Self>] = [
    .a(["pgmChange", ".x", ".x"], {
      let chan: EditorValueTransform = try $0.x(1)
      let val: EditorValueTransform = try $0.x(2)
      return {
        try .pgmChange(channel: chan.byteValue($0), value: val.byteValue($0))
      }
    }),
    .s(".a", { v in
      let count = v.arrCount()
      let fns: [ByteTransform] = try (1..<count).map {
        try v.x($0)
      }
      return { e in
        .sysex(try fns.flatMap { try $0.call([], e) })
      }
    }),
  ]
}
