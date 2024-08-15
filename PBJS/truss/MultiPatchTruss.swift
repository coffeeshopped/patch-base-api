
import PBAPI

extension MultiPatchTruss : JsParsable, JsToMidiParsable {
  
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
//      let createFile = try $0.any("createFile").xform(toMidiRules)
//      let parseBody = try $0.any("parseBody").xform(parseBodyRules)
//      let namePack = try? $0.any("namePack").xform(namePackRules)
//      let unpack = try? $0.any("unpack").xform(jsUnpackParsers)
      return .init(try $0.str("id"), trussMap: try $0.any("trussMap").xform(), namePath: try $0.path("namePath"), initFile: try $0.str("initFile"), fileDataCount: nil, defaultName: nil, createFileData: nil, parseBodyData: nil, validSizes: try $0.arrInt("validSizes"), includeFileDataCount: try $0.bool("includeFileDataCount"))
    }),
  ], "multiPatchTruss")
  
  static let toMidiRules: JsParseTransformSet<Core.ToMidiFn> = try! .init([
    (".f", { fn in
      try fn.checkFn()
      return { b, e in try fn.call([b, e]).arrByte() }
    }),
    (".a", { v in
      let count = v.arrCount()
      // the first element of the array is a fn mapping [SynthPath:[UInt8]] -> [UInt8]
      // the rest of the elements map [UInt8] -> [UInt8]
      let fn = try v.any(0).xform(toMidiRules)
      let singleFns: [SinglePatchTruss.Core.ToMidiFn] = try (1..<count).map {
        try v.atIndex($0).xform(SinglePatchTruss.toMidiRules)
      }

      return { b, e in
        let sub = try fn(b, e)
        return try singleFns.reduce(sub) { partialResult, fn in try fn(partialResult, e) }
      }
    }),
    (["+"], { v in
      let count = v.arrCount()
      let fns: [Core.ToMidiFn] = try (1..<count).map {
        try v.atIndex($0).xform(toMidiRules)
      }
      return { b, e in
        try fns.reduce([]) { try $0 + $1(b, e) }
      }
    }),
    (".p", {
      let path = try $0.path()
      return { b, e in
        b[path] ?? [] // TODO: should we throw here?
      }
    }),
//    ("e", { _ in { b, e in
//      switch e.first {
//      case let i as Int:
//        return [UInt8(i)]
//      default:
//        fatalError("TODO: handle other editor value types.")
//      }
//    } }), // returns editorValue
    ([".n"], {
      // array that starts with number: assume it's a byte array
      let bytes = try $0.arrByte()
      return { _, _ in bytes }
    }),
    (".n", {
      // number: return it as a byte array
      let byte = try $0.byte()
      return { _, _ in [byte] }
    }),
  ], "multiPatchTruss createFile")
}
