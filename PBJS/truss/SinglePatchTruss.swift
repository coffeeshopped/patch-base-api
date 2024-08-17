import PBAPI
import JavaScriptCore

extension SinglePatchTruss: JsParsable {
  
  static let jsParsers: JsParseTransformSet<Self> = try! .init([
    ([
      "type" : "singlePatch",
      "id" : ".s",
      "bodyDataCount" : ".n",
      "initFile" : ".s?",
      "parms" : ".a",
      "unpack" : ".x?",
      "parseBody" : ".x?",
      "createFile" : ".x?",
    ], {
      let parms = try $0.arr("parms").xform([Parm].jsParsers)
      let createFile = try (try? $0.any("createFile"))?.xform(toMidiRules)
      let bodyDataCount = try $0.int("bodyDataCount")
      
      var parseBodyFn: Core.ParseBodyDataFn? = nil
      if let parseBody = try? $0.any("parseBody") {
        parseBodyFn = try? parseBody.xform(parseBodyRules)
        if parseBodyFn == nil {
          // if it doesn't parse as a function, assume it's an int (parseOffset)
          parseBodyFn = parseBodyDataFn(parseOffset: try parseBody.int(), bodyDataCount: bodyDataCount)
        }
      }
      
      let namePack = try? $0.any("namePack").xform(namePackRules)
      let unpack = try? $0.any("unpack").xform(jsUnpackParsers)
      let initFile = (try? $0.str("initFile")) ?? ""
      
      return try .init(try $0.str("id"), bodyDataCount, namePackIso: namePack, params: parms.params(), initFile: initFile, defaultName: nil, createFileData: createFile, parseBodyData: parseBodyFn, validBundle: nil, pack: nil, unpack: unpack, randomize: nil)
    }),
  ], "singlePatchTruss")
  
  static let jsUnpackParsers: JsParseTransformSet<UnpackFn> = try! .init([
    ([
      "b" : ".s", // byte representation scheme
    ], {
      let scheme = try $0.any("b").str()
      return { bodyData, parm in
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
      }
    }),
    (".f", { fn in
      try fn.checkFn()
      return { bodyData, parm in
        try fn.call([bodyData, parm.toJS()])?.int()
      }
    }),
  ], "singlePatchUnpack")
    

  static let parseBodyRules: JsParseTransformSet<Core.ParseBodyDataFn> = try! .init([
    (["+"], { v in
      let fns = try (1..<v.arrCount()).map { try v.atIndex($0).xform(parseBodyFnRules) }
      return { b in try fns.flatMap { try $0(b) } }
      }),
    ([">"], { v in
      let fns = try (1..<v.arrCount()).map { try v.atIndex($0).xform(parseBodyFnRules) }
      return {
        try fns.reduce($0) { partialResult, fn in try fn(partialResult) }
      }
    }),
    (".a", { v in
      // otherwise, treat as an implicit "+"
      let fns = try v.map { try $0.xform(parseBodyFnRules) }
      return { b in try fns.flatMap { try $0(b) } }
    }),
    (".f", { fn in
      try fn.checkFn()
      return { try fn.call([$0]).arrByte() }
    }),
  ], "singlePatchTruss parseBody")
  
  static let parseBodyFnRules: JsParseTransformSet<(BodyData) throws -> BodyData> = try! .init([
    (["bytes", ".n", ".n"], {
      let start = try $0.int(1)
      let count = try $0.int(2)
      return { $0.safeBytes(offset: start, count: count) }
    }),
    ("denibblizeLSB", { _ in
      return { bytes in
        (bytes.count / 2).map {
          UInt8(bytes[$0 * 2].bits(0...3) + (bytes[$0 * 2 + 1].bits(0...3) << 4))
       }
      }
    })
  ], "singlePatchTruss parseBody Functions")
  
  static let namePackRules: JsParseTransformSet<NamePackIso> = try! .init([
    ([
      "type" : "filtered",
      "range" : ".a",
      "toBytes" : ".a",
      "toString" : ".a",
    ], {
      let rangeArr = try $0.arr("range")
      let range = (try rangeArr.int(0))..<(try rangeArr.int(1))
      let byteFilters = try $0.arr("toBytes").xformArr(nameFilterRules)
      let stringFilters = try $0.arr("toString").xformArr(nameFilterRules)
      // TODO: allow for a pad value other than 32 (for alt encodings)
      return NamePackIso.filtered(range) {
        let bytes = $0.compactMap { $0.asciiValue } // convert to uint8's
        return try bytes.compactMap { byte in
          try byteFilters.reduce(Optional(byte)) { partialResult, filter in
            guard let partialResult = partialResult else { return nil }
            return try filter(partialResult)
          }
        }.paddedTo(length: range.count, value: 32)
      } toName: {
        let bytes = try $0.compactMap { byte in
          try stringFilters.reduce(Optional(byte)) { partialResult, filter in
            guard let partialResult = partialResult else { return nil }
            return try filter(partialResult)
          }
        }
        return String(bytes: bytes, encoding: .ascii)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
      }

    }),
  ], "namePack")
  
  static let nameFilterRules: JsParseTransformSet<(UInt8) throws -> UInt8?> = try! .init([
    ("upper", { _ in
      { Character(Unicode.Scalar($0)).uppercased().first?.asciiValue }
    }),
    ("clean", { _ in
      { (32...126).contains($0) ? $0 : nil }
    }),
    (".f", { fn in
      try fn.checkFn()
      return {
        let result = try fn.call([$0])!
        if result.isNumber {
          return result.toNumber().uint8Value
        }
        else if result.isNull {
          return nil
        }
        throw JSError.error(msg: "Name byte filter returned an unexpected type.")
      }
    })
  ], "nameByteFilter")
  
}

// MARK: JsToMidiParsable

extension SinglePatchTruss: JsToMidiParsable {
  
  static let toMidiRules: JsParseTransformSet<Core.ToMidiFn> = try! .init([
    (["+"], { v in
      let fns: [Core.ToMidiFn] = try (1..<v.arrCount()).map {
        try v.atIndex($0).xform(toMidiRules)
      }
      return { b, e in
        try fns.flatMap { try $0(b, e) }
      }
    }),
    ([">"], { v in
      // treat as an array of functions, with the output of each function being fed as input to the next function (chaining).
      let fns: [Core.ToMidiFn] = try (1..<v.arrCount()).map {
        try v.atIndex($0).xform(toMidiRules)
      }
      return { b, e in
        try fns.reduce(b) { partialResult, fn in try fn(partialResult, e) }
      }
    }),
    (["trussValues", ".d", ".a", ".f"], {
      let t = try $0.atIndex(1).xform(JsSysex.trussRules)
      let paths: [SynthPath] = try $0.atIndex(2).map { try $0.path() }
      let fn = try $0.fn(3)
      return { bodyData, e in
        try paths.map {
          switch t {
          case let single as SinglePatchTruss:
            let v = single.getValue(bodyData, path: $0) ?? 0
            // truss return Int. So, map Int -> UInt8 via passed-in mapping fn.
            return try fn.call([v]).byte()
          default:
            throw JSError.error(msg: "Unknown truss type passed to trussValue.")
          }
        }
      }
    }),
    (["byte", ".n"], {
      let byte = try $0.int(1)
      return { b, e in
        guard byte < b.count else {
          throw JSError.error(msg: "byte: index (\(byte)) must be less than data length (\(b.count)")
        }
        return [b[byte]]
      }
    }),
    (["enc", ".s"], {
      let bytes = try $0.str(1).sysexBytes()
      return { _, _ in bytes }
    }),
    (["yamCmd", ".x"], {
      let cmdBytes = try $0.any(1).xform(toMidiRules)
      // second arg is optional, defaults to "b"
      let bodyData = try (try? $0.any(2))?.xform(toMidiRules)
      return { b, e in Yamaha.sysexData(cmdBytesWithChannel: try cmdBytes(b, e), bodyBytes: try bodyData?(b ,e) ?? b) }
    }),
    (["yamFetch", ".x"], {
      let chan = try $0.any(1).xform(toMidiRules)
      // second arg is optional, defaults to "b"
      let cmdBytes = try (try? $0.any(2))?.xform(toMidiRules)
      return { b, e in
        Yamaha.fetchRequestBytes(channel: Int(try chan(b, e).first ?? 0), cmdBytes: try cmdBytes?(b ,e) ?? b)
      }
    }),
    (["yamParm", ".x"], {
      let chan = try $0.any(1).xform(toMidiRules)
      // second arg is optional, defaults to "b"
      let cmdBytes = try (try? $0.any(2))?.xform(toMidiRules)
      return { b, e in
        Yamaha.paramData(channel: Int(try chan(b, e).first ?? 0), cmdBytes: try cmdBytes?(b ,e) ?? b)
      }
    }),
    ("b", { _ in { b, e in b } }), // returns itself
    (".n", {
      // number: return it as a byte array
      let byte = try $0.byte()
      return { _, _ in [byte] }
    }),
    (".s", {
      // if string, first see if it's an editorValueTransform
      if let fn = tryAsEditorValueTransform($0) {
        return fn
      }

      // string: treat as singleArg fn
      let fnKey = try $0.str()
      guard let fn = singleArgCreateFileFnRules[fnKey] else {
        throw JSError.error(msg: "Unknown singleArgCreateFileFn: \(fnKey)")
      }
      
      guard let arg = try? $0.any(1) else {
        return { b, e in fn(b) }
      }
      let bb = try arg.xform(toMidiRules)
      return { b, e in fn(try bb(b, e)) }
    }),
    (".a", { v in
      // if array, first see if it's an editorValueTransform
      if let fn = tryAsEditorValueTransform(v) {
        return fn
      }

      // otherwise, treat as an implicit "+"
      let fns: [Core.ToMidiFn] = try v.map { try $0.xform(toMidiRules) }
      return { b, e in try fns.flatMap { try $0(b, e) } }
    }),
    (".f", { fn in
      try fn.checkFn()
      return { b, e in try fn.call([b, e]).arrByte() }
    }),
  ], "singlePatchTruss createFile")

  static func tryAsEditorValueTransform(_ value: JSValue) -> Core.ToMidiFn? {
    guard let evt = try? value.xform(EditorValueTransform.jsParsers) else {
      return nil
    }
    return { b, e in [try e?.byteValue(evt) ?? 0] }
  }
  
  static let singleArgCreateFileFnRules: [String:(BodyData) -> BodyData] = [
    "nibblizeLSB": {
      $0.flatMap { [UInt8($0.bits(0...3)), UInt8($0.bits(4...7))] }
    },
    "checksum": {
      [UInt8($0.map{ Int($0) }.reduce(0, +) & 0x7f)]
    },
  ]
  
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
