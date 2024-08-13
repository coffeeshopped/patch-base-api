
import PBAPI
import JavaScriptCore

extension RxMidi.FetchCommand: JsParsable, JsArrayParsable {
  
  static let jsParsers: JsParseTransformSet<Self> = try! .init([
    (["send", ".a"], {
      return .sendMsg(try $0.arr(1).xform(MidiMessage.jsParsers))
    }),
  ], "fetch command")

  static let jsArrayParsers = try! jsParsers.arrayParsers()

  static let dynamicRules: JsParseTransformSet<(AnySynthEditor) throws -> Self> = try! .init([
    (["send", ".x"], {
      let msg = try $0.any(1).xform(MidiMessage.dynamicRules)
      return { .sendMsg(try msg($0)) }
    }),
  ], "dynamic midi msg")

}
