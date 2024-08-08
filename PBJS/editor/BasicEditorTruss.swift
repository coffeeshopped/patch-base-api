
import JavaScriptCore
import PBAPI

extension BasicEditorTruss: JsParsable {
  
  static let jsParsers: JsParseTransformSet<Self> = try! .init([
    ([
      "name" : ".s",
      "trussMap" : ".a",
      "fetchTransforms" : ".a",
      "midiOuts" : ".a",
      "midiChannels" : ".a",
      "slotTransforms" : ".a?",
    ], {
      let trussMap = try $0.arr("trussMap").xformArr(pathPairRules(JsSysex.trussRules))
      var t = BasicEditorTruss(try $0.str("name"), truss: trussMap)
      t.fetchTransforms = try $0.arr("fetchTransforms").xform()
      t.midiOuts = try $0.arr("midiOuts").xform()
      t.midiChannels = try $0.arr("midiChannels").xform()
      
      t.slotTransforms = [:]
      if let x = try? $0.any("slotTransforms") {
        t.slotTransforms = try x.xform()
      }
      
      return t
    }),
  ], "editor")

  static func pathPairRules<Output:Any>(_ subrules: JsParseTransformSet<Output>) throws -> JsParseTransformSet<(SynthPath, Output)> {
    try JsParseTransformSet<(SynthPath, Output)>.init([
      ([".p", ".x"], { (try $0.path(0), try $0.any(1).xform(subrules)) }),
    ], "\(subrules.name) pairs")
  }
  
}