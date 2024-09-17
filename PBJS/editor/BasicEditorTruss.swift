
import JavaScriptCore
import PBAPI

extension BasicEditorTruss: JsParsable {
  
  static let jsParsers: JsParseTransformSet<Self> = try! .init([
//    ([
//      "rolandModelId" : ".a",
//      "addressCount" : ".n",
//      "name" : ".s",
//      "map" : ".a",
//    ], {
//      let sysexWerk = try RolandSysexTrussWerk(modelId: $0.x("rolandModelId"), addressCount: $0.x("addressCount"))
//      let map: [RolandEditorTrussWerk.MapItem] = try $0.x("map")
//      var t = BasicEditorTruss(try $0.x("name"), truss: [])
//      return t
//    }),
    ([
      "name" : ".s",
      "trussMap" : ".a",
      "fetchTransforms" : ".a",
      "midiOuts" : ".a",
      "midiChannels" : ".a",
      "slotTransforms" : ".a?",
    ], {
      let trussMap = try $0.arr("trussMap").xformArr(pathPairRules(JsSysex.trussRules))
      var t = BasicEditorTruss(try $0.x("name"), truss: trussMap)
      t.fetchTransforms = try $0.arr("fetchTransforms").x()
      t.midiOuts = try $0.arr("midiOuts").xform()
      t.midiChannels = try $0.arr("midiChannels").x()
      
      t.slotTransforms = [:]
      if let x = try? $0.any("slotTransforms") {
        t.slotTransforms = try x.x()
      }
      
      return t
    }),
  ], "editor")

  static func pathPairRules<Output:Any>(_ subrules: JsParseTransformSet<Output>) throws -> JsParseTransformSet<(SynthPath, Output)> {
    try JsParseTransformSet<(SynthPath, Output)>.init([
      ([".p", ".x"], { try ($0.x(0), $0.any(1).xform(subrules)) }),
    ], "\(subrules.name) pairs")
  }
  
}
