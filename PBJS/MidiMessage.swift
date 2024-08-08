
import PBAPI

extension MidiMessage: JsParsable {
  
  static let jsParsers: JsParseTransformSet<Self> = try! .init([
    ([0xf0], { .sysex(try $0.arrByte()) }),
    (["syx", ".a"], { .sysex(try $0.arr(1).arrByte()) }),
    (["pgmChange", ".n", ".n"], { .pgmChange(channel: try $0.byte(1), value: try $0.byte(2)) }),
  ], "midi message")

  
}
