
import PBAPI

extension MultiPatchTruss : JsParsable {
  
  static let jsParsers: JsParseTransformSet<Self> = try! .init([
    ([
      "type" : "multiPatch",
      "id" : ".s",
      "trussMap" : ".a",
      "namePath" : ".p",
//      "bodyDataCount" : ".n",
      "initFile" : ".s",
//      "unpack" : ".x",
//      "createFile" : ".x",
      "validSizes": ".a",
      "includeFileDataCount": ".b",
    ], {
//      let parms = try $0.arr("parms").xform([Parm].jsParsers)
//      let createFile = try $0.any("createFile").xform(createFileRules)
//      let parseBody = try $0.any("parseBody").xform(parseBodyRules)
//      let namePack = try? $0.any("namePack").xform(namePackRules)
//      let unpack = try? $0.any("unpack").xform(jsUnpackParsers)
      return .init(try $0.str("id"), trussMap: try $0.any("trussMap").xform(), namePath: try $0.path("namePath"), initFile: try $0.str("initFile"), fileDataCount: nil, defaultName: nil, createFileData: nil, parseBodyData: nil, validSizes: try $0.arrInt("validSizes"), includeFileDataCount: try $0.bool("includeFileDataCount"))
    }),
  ], "singlePatchTruss")
  
}
