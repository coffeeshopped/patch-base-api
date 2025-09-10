
import PBAPI

extension MidiMessage: JsParsable {
  
  public static let jsRules: [JsParseRule<Self>] = [
    .b(0xf0, [], { .sysex(try $0.x()) }),
    .a("syx", [[UInt8].self], { try .sysex($0.x(1)) }),
    .a("pgmChange", [UInt8.self, UInt8.self], { try .pgmChange(channel: $0.x(1), value: $0.x(2)) }),
  ]
  
}
