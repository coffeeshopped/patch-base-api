import PBAPI
import JavaScriptCore

extension SinglePatchTruss: JsParsable {
  
  static let r = """
{
  single : String,
  initFile? : String,
  parms : [Parm],
  pack : SinglePatchTruss.PackFn?,
  unpack : SinglePatchTruss.UnpackFn?,
  parseBody : SinglePatchTruss.Core.FromMidiFn?,
  createFile : SinglePatchTruss.Core.ToMidiFn?,
}
"""
  static let nuJsRules: [NuJsParseRule<Self>] = [
    .d([
      "single" : String.self,
      "initFile?" : String.self,
      "parms" : [Parm].self,
      "pack?" : SinglePatchTruss.PackFn.self,
      "unpack?" : SinglePatchTruss.UnpackFn.self,
      "parseBody?" : SinglePatchTruss.Core.FromMidiFn.self,
      "createFile?" : SinglePatchTruss.Core.ToMidiFn.self,
    ], {
      let parms: [Parm] = try $0.x("parms")
      let initFile = (try $0.xq("initFile")) ?? ""
      
      return try .init($0.x("single"), namePackIso: $0.xq("namePack"), params: parms.params(), initFile: initFile, defaultName: nil, createFileData: $0.xq("createFile"), parseBodyData: $0.xq("parseBody"), validBundle: nil, pack: $0.xq("pack"), unpack: $0.xq("unpack"), randomize: nil)
    }),
  ]
  
  static let jsRules: [JsParseRule<Self>] = [
    .d([
      "type" : "singlePatch",
      "id" : ".s",
      "initFile" : ".s?",
      "parms" : ".a",
      "pack" : ".x?",
      "unpack" : ".x?",
      "parseBody" : ".x?",
      "createFile" : ".x?",
    ], {
      let parms: [Parm] = try $0.x("parms")
      let initFile = (try $0.xq("initFile")) ?? ""
      
      return try .init($0.x("id"), namePackIso: $0.xq("namePack"), params: parms.params(), initFile: initFile, defaultName: nil, createFileData: $0.xq("createFile"), parseBodyData: $0.xq("parseBody"), validBundle: nil, pack: $0.xq("pack"), unpack: $0.xq("unpack"), randomize: nil)
    }),
    // newer API, matching Roland werks
    // no "type", but rather the type (single, multi, etc) can be the key for the ID
    .d([
      "single" : ".s",
      "initFile" : ".s?",
      "parms" : ".a",
      "pack" : ".x?",
      "unpack" : ".x?",
      "parseBody" : ".x?",
      "createFile" : ".x?",
    ], {
      let parms: [Parm] = try $0.arr("parms").x()
      let initFile = (try $0.xq("initFile")) ?? ""
      
      return try .init($0.x("single"), namePackIso: $0.xq("namePack"), params: parms.params(), initFile: initFile, defaultName: nil, createFileData: $0.xq("createFile"), parseBodyData: $0.xq("parseBody"), validBundle: nil, pack: $0.xq("pack"), unpack: $0.xq("unpack"), randomize: nil)
    }),
  ]

}

extension SinglePatchTruss.PackFn: JsParsable {
  
  static let jsRules: [JsParseRule<Self>] = [
  ]
}

extension SinglePatchTruss.UnpackFn: JsParsable {
  
  static let nuJsRules: [NuJsParseRule<Self>] = [
    .d([
      "b" : String.self, // byte representation scheme
    ], {
      let scheme: String = try $0.x("b")
      return .fn({ bodyData, parm in
        guard let index = parm.b else {
          throw JSError.error(msg: "Parm did not have b specified.")
        }
        guard index < bodyData.count else {
          throw JSError.error(msg: "Byte index out of bounds of body data.")
        }
        let byte = bodyData[index]
        switch scheme {
        case "2comp":
          return Int(Int8(bitPattern: byte))
        default:
          return Int(byte)
        }
      })
    }),
    .f({ fn in
      try fn.checkFn()
      return .fn({ bodyData, parm in
        try fn.call([bodyData, parm.toJS()], exportOrigin: nil)?.x()
      })
    }),
  ]
  
  static let jsRules: [JsParseRule<Self>] = [
    .d([
      "b" : ".s", // byte representation scheme
    ], {
      let scheme: String = try $0.x("b")
      return .fn({ bodyData, parm in
        guard let index = parm.b else {
          throw JSError.error(msg: "Parm did not have b specified.")
        }
        guard index < bodyData.count else {
          throw JSError.error(msg: "Byte index out of bounds of body data.")
        }
        let byte = bodyData[index]
        switch scheme {
        case "2comp":
          return Int(Int8(bitPattern: byte))
        default:
          return Int(byte)
        }
      })
    }),
    .s(".f", { fn in
      try fn.checkFn()
      return .fn({ bodyData, parm in
        try fn.call([bodyData, parm.toJS()], exportOrigin: nil)?.x()
      })
    }),
  ]
  
}
