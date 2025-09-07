
import PBAPI

extension MidiMessage: JsParsable {
  
  public static let jsRules: [JsParseRule<Self>] = [
    .b(0xf0, [], { .sysex(try $0.x()) }),
    .a("syx", [[UInt8].self], { try .sysex($0.x(1)) }),
    .a("pgmChange", [UInt8.self, UInt8.self], { try .pgmChange(channel: $0.x(1), value: $0.x(2)) }),
  ]
  
  public static let dynamicRules: [JsParseRule<(AnySynthEditor) throws -> Self>] = [
    .a("pgmChange", [EditorValueTransform.self, EditorValueTransform.self], {
      let chan: EditorValueTransform = try $0.x(1)
      let val: EditorValueTransform = try $0.x(2)
      return {
        try .pgmChange(channel: chan.byteValue($0), value: val.byteValue($0))
      }
    }),
    .arr([JsObj.self, ByteTransform.self], { v in
      let count = v.arrCount()
      let fns: [ByteTransform] = try (1..<count).map {
        try v.x($0)
      }
      return { e in
        .sysex(try fns.flatMap { try $0.call([], e) })
      }
    }, "chain"),
  ]
}
