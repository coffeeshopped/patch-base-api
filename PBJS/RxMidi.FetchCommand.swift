
import PBAPI
import JavaScriptCore

extension RxMidi.FetchCommand: JsParsable {
  
  public static let jsRules: [JsParseRule<Self>] = [
    .a("send", [MidiMessage.self], { try .sendMsg($0.x(1)) }),
  ]
  
}
