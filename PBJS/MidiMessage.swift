
import PBAPI

extension MidiMessage: JsParsable {
  
  static let jsParsers: JsParseTransformSet<Self> = try! .init([
    ([0xf0], { .sysex(try $0.arrByte()) }),
    (["syx", ".a"], { .sysex(try $0.arr(1).arrByte()) }),
    (["pgmChange", ".n", ".n"], { .pgmChange(channel: try $0.byte(1), value: try $0.byte(2)) }),
  ], "midi message")

  static let dynamicRules: JsParseTransformSet<(AnySynthEditor) throws -> Self> = try! .init([
    (["pgmChange", ".x", ".x"], {
      let chan: EditorValueTransform = try $0.xform(1)
      let val: EditorValueTransform = try $0.xform(2)
      return {
        .pgmChange(channel: UInt8(try $0.intValue(chan)), value: UInt8(try $0.intValue(val)))
      }
    }),
    (["+"], { v in
      let count = v.arrCount()
      let fns: [SinglePatchTruss.Core.ToMidiFn] = try (1..<count).map {
        try v.atIndex($0).xform(SinglePatchTruss.toMidiRules)
      }
      return { e in
        .sysex(try fns.reduce([]) { try $0 + $1([], e) })
      }
    }),

  ], "dynamic midi msg")
}
