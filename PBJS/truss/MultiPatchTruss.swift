
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
      return try .init($0.x("id"), trussMap: $0.any("trussMap").xform(), namePath: $0.x("namePath"), initFile: $0.x("initFile"), fileDataCount: nil, defaultName: nil, createFileData: nil, parseBodyData: nil, validSizes: $0.arrInt("validSizes"), includeFileDataCount: $0.x("includeFileDataCount"))
    }),
  ], "multiPatchTruss")
  
}

extension MultiPatchTruss: JsToMidiParsable {
  
  static let toMidiRules: JsParseTransformSet<Core.ToMidiFn> = try! .init([
    (["+"], { v in
      let count = v.arrCount()
      let fns: [Core.ToMidiFn] = try (1..<count).map {
        try v.atIndex($0).xform(toMidiRules)
      }
      return .fn { b, e in try fns.reduce([]) { try $0 + $1.call(b, e) } }
    }),
    ([".p"], { v in
      // the first element of the array is a path to fetch subdata
      // the rest of the elements map [UInt8] -> [UInt8]
      let path: SynthPath = try v.x(0)
      let singleFns: [SinglePatchTruss.Core.ToMidiFn] = try (1..<v.arrCount()).map {
        try v.atIndex($0).xform(SinglePatchTruss.toMidiRules)
      }

      return .fn { b, e in
        let sub = b[path] ?? []
        return try singleFns.reduce(sub) { partialResult, fn in try fn.call(partialResult, e) }
      }
    }),
    (".n", {
      // number: return it as a byte array
      return .const([try $0.x()])
    }),
    (".a", { v in
      // implicit "+"
      let fns: [Core.ToMidiFn] = try v.map { try $0.xform(toMidiRules) }
      return .fn { b, e in try fns.reduce([]) { try $0 + $1.call(b, e) } }
    }),
    (".f", { fn in
      try fn.checkFn()
      return .fn { b, e in try fn.call([b, e]).arrByte() }
    }),
  ], "multiPatchTruss toMidiRules")
  
  static func makeMidiPairs(_ fn: JSValue, _ bodyData: BodyData, _ editor: AnySynthEditor, _ vals: [Any?]) throws -> [(MidiMessage, Int)] {
    // fn can be a JS function
    // or it can be something that should be parsed as a createFile...
    let mapVal = fn.isFn ? try fn.call(vals) : fn
    return try mapVal!.map {
      if let msg = try? $0.arr(0).xform(MidiMessage.jsParsers) {
        return (msg, try $0.x(1))
      }
      else {
        // if what's returned doesn't match a midi msg rule, then treat it like a createFileFn
        // TODO: here is where some caching needs to happen. Perhaps that caching
        // could be implemented in the JsParseTransformSet struct.
        let fn = try $0.atIndex(0).xform(toMidiRules)
        return (.sysex(try fn.call(bodyData, editor)), try $0.x(1))
      }
    }
  }
}
