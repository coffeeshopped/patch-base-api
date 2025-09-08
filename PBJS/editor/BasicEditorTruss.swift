
import JavaScriptCore
import PBAPI

extension EditorTruss: JsParsable {
  
  public static let jsRules: [JsParseRule<Self>] = [
    .init(.d([
      "name" : String.self,
//      "trussMap" : [].self,
      "fetchTransforms" : [SynthPath:FetchTransform].self,
      "midiOuts" : [SynthPath:MidiTransform].self,
      "midiChannels" : [SynthPath:MidiChannelTransform].self,
      "slotTransforms?" : [SynthPath:MemSlot.Transform].self,
      "extraParamOuts?" : [SynthPath:ParamOutTransform].self,
    ]),  {
      let ppr = pathPairRule(JsSysex.trussRules)
      let trussMap = try $0.arr("trussMap").map { try ppr.transform($0) }
      var t = EditorTruss(try $0.x("name"), truss: trussMap)
      t.fetchTransforms = try $0.x("fetchTransforms")
      t.midiOuts = try $0.x("midiOuts")
      t.midiChannels = try $0.x("midiChannels")
      t.extraParamOuts = try $0.xq("extraParamOuts") ?? [:]
      t.slotTransforms = try $0.xq("slotTransforms") ?? [:]
      return t
    }, "basic"),
    .d([
      "rolandModelId" : [UInt8].self,
      "addressCount" : Int.self,
      "name" : String.self,
      "map" : [RolandEditorTrussWerk.MapItem].self,
      "deviceId?" : EditorValueTransform.self,
      "midiChannels" : [SynthPath:MidiChannelTransform].self,
      "slotTransforms" : [SynthPath:MemSlot.Transform].self,
      "extraParamOuts?" : [SynthPath:ParamOutTransform].self,
    ], {
      let sysexWerk = try RolandSysexTrussWerk(modelId: $0.x("rolandModelId"), addressCount: $0.x("addressCount"))
      let map: [RolandEditorTrussWerk.MapItem] = try $0.x("map")
      let werk = try sysexWerk.editorWerk($0.x("name"), deviceId: $0.xq("deviceId"), map: map)
      var t = try EditorTruss($0.x("name"), truss: [(.init([.deviceId]), RolandDeviceIdSettingsTruss)] + werk.sysexMap())
      t.fetchTransforms = werk.defaultFetchTransforms()
      t.midiOuts = try werk.midiOuts()
      t.midiChannels = try $0.x("midiChannels")
      t.extraParamOuts = try $0.xq("extraParamOuts") ?? [:]
      t.slotTransforms = try $0.xq("slotTransforms") ?? [:]

      return t
    }, "roland"),
  ]

  static func pathPairRule<Output:Any>(_ subrules: [JsParseRule<Output>]) -> JsParseRule<(SynthPath, Output)> {
    .arr([SynthPath.self, JsObj.self], { try ($0.x(0), $0.any(1).xform(subrules)) }, "pathPair")
  }
  
}
