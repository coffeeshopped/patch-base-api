
import PBAPI
import JavaScriptCore

extension RxMidi.FetchCommand: JsParsable, JsArrayParsable {
  
  static let jsParsers: JsParseTransformSet<Self> = try! .init([
    (["send", ".a"], {
      return .sendMsg(try $0.arr(1).xform(MidiMessage.jsParsers))
    }),
  ], "fetch command")

  static let jsArrayParsers = try! jsParsers.arrayParsers()

}
