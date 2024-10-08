
import PBAPI

extension MidiMessage: JsParsable {
  
  static let jsParsers: JsParseTransformSet<Self> = try! .init([
    ([0xf0], { .sysex(try $0.x()) }),
    (["syx", ".a"], { .sysex(try $0.arr(1).x()) }),
    (["pgmChange", ".n", ".n"], { try .pgmChange(channel: $0.x(1), value: $0.x(2)) }),
  ], "midi message")

  static let dynamicRules: JsParseTransformSet<(AnySynthEditor) throws -> Self> = try! .init([
    (["pgmChange", ".x", ".x"], {
      let chan: EditorValueTransform = try $0.x(1)
      let val: EditorValueTransform = try $0.x(2)
      return {
        .pgmChange(channel: UInt8(try $0.intValue(chan)), value: UInt8(try $0.intValue(val)))
      }
    }),
    (".a", { v in
      let count = v.arrCount()
      let fns: [SinglePatchTruss.Core.ToMidiFn] = try (1..<count).map {
        try v.x($0)
      }
      return { e in
        .sysex(try fns.reduce([]) { try $0 + $1.call([], e).bytes() })
      }
    }),

  ], "dynamic midi msg")
}
