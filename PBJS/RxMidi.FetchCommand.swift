
import PBAPI
import JavaScriptCore

extension RxMidi.FetchCommand: JsParsable {
  
  static let nuJsRules: [NuJsParseRule<Self>] = [
    .a("send", [MidiMessage.self], { try .sendMsg($0.x(1)) }),
  ]
  
  static let jsRules: [JsParseRule<Self>] = [
    .a(["send", ".a"], { try .sendMsg($0.x(1)) }),
  ]

  static let dynamicRules: [NuJsParseRule<(AnySynthEditor) throws -> Self>] = [
    .a("send", [JsObj.self], {
      let msg = try $0.any(1).xform(MidiMessage.dynamicRules)
      return { .sendMsg(try msg($0)) }
    }),
  ]

}
