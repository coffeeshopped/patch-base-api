
import PBAPI
import JavaScriptCore

extension MidiChannelTransform: JsParsable {
  
  static let jsParsers: JsParseTransformSet<Self> = try! .init([
    ("basic", { _ in .basic(map: nil) }),
  ], "midiChannel")

  
}
