
import PBAPI
import JavaScriptCore

extension MultiPatchTruss : JsParsable {
  
  public static let jsRules: [JsParseRule<Self>] = [
    .d([
      "multiPatch" : String.self,
      "trussMap" : [JsObj].self,
      "namePath" : SynthPath.self,
//      "bodyDataCount" : ".n",
      "initFile" : String.self,
//      "unpack" : ".x",
//      "createFile" : ".x",
      "validSizes": [Int].self,
      "includeFileDataCount": Bool.self,
    ], {
//      let parms = try $0.arr("parms").xform([Parm].jsParsers)
//      let createFile = try $0.any("createFile").xform(MultiPatchTruss.bankToMidiRules)
//      let parseBody = try $0.any("parseBody").xform(parseBodyRules)
//      let namePack = try? $0.any("namePack").xform(namePackRules)
//      let unpack = try? $0.any("unpack").xform(jsUnpackParsers)
      return try .init($0.x("multiPatch"), trussMap: $0.any("trussMap").x(), namePath: $0.x("namePath"), initFile: $0.x("initFile"), fileDataCount: nil, defaultName: nil, createFileData: nil, parseBodyData: nil, validSizes: $0.x("validSizes"), includeFileDataCount: $0.x("includeFileDataCount"))
    }, "basic"),
  ]
  
}
