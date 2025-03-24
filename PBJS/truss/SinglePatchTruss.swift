import PBAPI
import JavaScriptCore

extension SinglePatchTruss: JsParsable {
  
  static let jsRules: [JsParseRule<Self>] = [
    .d([
      "type" : "singlePatch",
      "id" : ".s",
      "bodyDataCount" : ".n",
      "initFile" : ".s?",
      "parms" : ".a",
      "unpack" : ".x?",
      "parseBody" : ".x?",
      "createFile" : ".x?",
    ], {
      let parms: [Parm] = try $0.arr("parms").x()
      let bodyDataCount: Int = try $0.x("bodyDataCount")
      
      var parseBodyFn: Core.ParseBodyDataFn? = nil
      if let parseBody = try? $0.any("parseBody") {
        parseBodyFn = try? parseBody.xform(parseBodyRules)
        if parseBodyFn == nil {
          // if it doesn't parse as a function, assume it's an int (parseOffset)
          parseBodyFn = parseBodyDataFn(parseOffset: try parseBody.x(), bodyDataCount: bodyDataCount)
        }
      }
      
      let namePack: NamePackIso? = try $0.xq("namePack")
      let unpack = try? $0.any("unpack").xform(jsUnpackParsers)
      let initFile = (try $0.xq("initFile")) ?? ""
      
      return try .init(try $0.x("id"), bodyDataCount, namePackIso: namePack, params: parms.params(), initFile: initFile, defaultName: nil, createFileData: $0.xq("createFile"), parseBodyData: parseBodyFn, validBundle: nil, pack: nil, unpack: unpack, randomize: nil)
    }),
  ]
  
  static let jsUnpackParsers: [JsParseRule<UnpackFn>] = [
    .d([
      "b" : ".s", // byte representation scheme
    ], {
      let scheme: String = try $0.x("b")
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
    .s(".f", { fn in
      try fn.checkFn()
      return { bodyData, parm in
        try fn.call([bodyData, parm.toJS()], exportOrigin: nil)?.x()
      }
    }),
  ]
    

  static let parseBodyRules: [JsParseRule<Core.ParseBodyDataFn>] = [
    .a(["+"], { v in
      let fns = try (1..<v.arrCount()).map { try v.atIndex($0).xform(parseBodyRules) }
      return { b in try fns.flatMap { try $0(b) } }
      }),
    .a([">"], { v in
      let fns = try (1..<v.arrCount()).map { try v.atIndex($0).xform(parseBodyRules) }
      return {
        try fns.reduce($0) { partialResult, fn in try fn(partialResult) }
      }
    }),
    
    
    .a(["bytes", ".d"], {
      let d = try $0.obj(1)
      let start: Int = try d.x("start")
      if let count: Int = try d.xq("count") {
        return { $0.safeBytes(offset: start, count: count) }
      }
      else if let end: Int = try d.xq("end") {
        if end < 0 {
          return { $0.safeBytes(start..<($0.count - end)) }
        }
        else if end <= start {
          throw JSError.error(msg: "'end' must be greater than 'start', or negative")
        }
        else {
          return { $0.safeBytes(start..<end) }
        }
      }
      throw JSError.error(msg: "No argument for end of byte range found.")
    }),
    .s("denibblizeLSB", { _ in
      return { bytes in
        (bytes.count / 2).map {
          UInt8(bytes[$0 * 2].bits(0...3) + (bytes[$0 * 2 + 1].bits(0...3) << 4))
       }
      }
    }),
    
    
    .s(".a", { v in
      // otherwise, treat as an implicit "+"
      let fns = try v.map { try $0.xform(parseBodyRules) }
      return { b in try fns.flatMap { try $0(b) } }
    }),
    .s(".f", { fn in
      try fn.checkFn()
      return { try fn.call([$0], exportOrigin: nil).x() }
    }),
  ]
  
//  static let parseBodyFnRules: JsParseTransformSet<(BodyData) throws -> BodyData> = try! .init([
//    (["bytes", ".d"], {
//      let d = try $0.obj(1)
//      let start: Int = try d.x("start")
//      if let count: Int = try d.xq("count") {
//        return { $0.safeBytes(offset: start, count: count) }
//      }
//      else if let end: Int = try d.xq("end") {
//        if end < 0 {
//          return { $0.safeBytes(start..<($0.count - end)) }
//        }
//        else if end <= start {
//          throw JSError.error(msg: "'end' must be greater than 'start', or negative")
//        }
//        else {
//          return { $0.safeBytes(start..<end) }
//        }
//      }
//      throw JSError.error(msg: "No argument for end of byte range found.")
//    }),
//    ("denibblizeLSB", { _ in
//      return { bytes in
//        (bytes.count / 2).map {
//          UInt8(bytes[$0 * 2].bits(0...3) + (bytes[$0 * 2 + 1].bits(0...3) << 4))
//       }
//      }
//    }),
//  ], "singlePatchTruss parseBody Functions")

}
