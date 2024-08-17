
import PBAPI
import JavaScriptCore

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
//      let createFile = try $0.any("createFile").xform(toMidiRules)
//      let parseBody = try $0.any("parseBody").xform(parseBodyRules)
//      let namePack = try? $0.any("namePack").xform(namePackRules)
//      let unpack = try? $0.any("unpack").xform(jsUnpackParsers)
      return .init(try $0.str("id"), trussMap: try $0.any("trussMap").xform(), namePath: try $0.path("namePath"), initFile: try $0.str("initFile"), fileDataCount: nil, defaultName: nil, createFileData: nil, parseBodyData: nil, validSizes: try $0.arrInt("validSizes"), includeFileDataCount: try $0.bool("includeFileDataCount"))
    }),
  ], "multiPatchTruss")
  
}

extension MultiPatchTruss: JsToMidiParsable {
  
  static let toMidiRules: JsParseTransformSet<Core.ToMidiFn> = try! .init([
    (".f", { fn in
      try fn.checkFn()
      return { b, e in try fn.call([b, e]).arrByte() }
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
    (["sub", ".p"], {
      let path = try $0.path(1)
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
    (".n", {
      // number: return it as a byte array
      let byte = try $0.byte()
      return { _, _ in [byte] }
    }),
  ], "multiPatchTruss toMidiRules")
  
  static func makeMidiPairs(_ fn: JSValue, _ bodyData: BodyData, _ editor: AnySynthEditor, _ vals: [Any?]) throws -> [(MidiMessage, Int)] {
    // fn can be a JS function
    // or it can be something that should be parsed as a createFile...
    let mapVal = fn.isFn ? try fn.call(vals) : fn
    return try mapVal!.map {
      if let msg = try? $0.arr(0).xform(MidiMessage.jsParsers) {
        return (msg, try $0.any(1).int())
      }
      else {
        // if what's returned doesn't match a midi msg rule, then treat it like a createFileFn
        // TODO: here is where some caching needs to happen. Perhaps that caching
        // could be implemented in the JsParseTransformSet struct.
        let fn = try $0.atIndex(0).xform(toMidiRules)
        return (.sysex(try fn(bodyData, editor)), try $0.any(1).int())
      }
    }
  }
}
