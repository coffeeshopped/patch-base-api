
import PBAPI
import JavaScriptCore

extension RxMidi.FetchCommand: JsParsable {
  
  static let jsRules: [JsParseRule<Self>] = [
    .a(["send", ".a"], {
      return .sendMsg(try $0.arr(1).xform(MidiMessage.jsParsers))
    }),
  ]

  static let dynamicRules: JsParseTransformSet<(AnySynthEditor) throws -> Self> = try! .init([
    (["send", ".x"], {
      let msg = try $0.any(1).xform(MidiMessage.dynamicRules)
      return { .sendMsg(try msg($0)) }
    }),
  ], "dynamic midi msg")

}
