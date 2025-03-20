
import JavaScriptCore
import PBAPI

extension BasicEditorTruss: JsParsable {
  
  static let jsRules: [JsParseRule<Self>] = [
    ([
      "rolandModelId" : ".a",
      "addressCount" : ".n",
      "name" : ".s",
      "map" : ".a",
      "deviceId" : ".x?",
    ], {
      let sysexWerk = try RolandSysexTrussWerk(modelId: $0.x("rolandModelId"), addressCount: $0.x("addressCount"))
      let map: [RolandEditorTrussWerk.MapItem] = try $0.x("map")
      let werk = try sysexWerk.editorWerk($0.x("name"), deviceId: $0.xq("deviceId"), map: map)
      var t = try BasicEditorTruss($0.x("name"), truss: [(.init([.deviceId]), RolandDeviceIdSettingsTruss)] + werk.sysexMap())
      t.fetchTransforms = werk.defaultFetchTransforms()
      t.midiOuts = try werk.midiOuts()
      t.midiChannels = try $0.x("midiChannels")
      t.extraParamOuts = try $0.x("extraParamOuts")
      return t
    }),
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
      t.midiChannels = try $0.x("midiChannels")
      
      t.slotTransforms = [:]
      if let x = try? $0.any("slotTransforms") {
        t.slotTransforms = try x.x()
      }
      
      return t
    }),
  ])

  static func pathPairRules<Output:Any>(_ subrules: JsParseTransformSet<Output>) throws -> JsParseTransformSet<(SynthPath, Output)> {
    try JsParseTransformSet<(SynthPath, Output)>.init([
      ([".p", ".x"], { try ($0.x(0), $0.any(1).xform(subrules)) }),
    ], "(SynthPath, \(subrules.name))")
  }
  
}
