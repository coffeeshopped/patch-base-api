
import PBAPI
import JavaScriptCore

extension Parm: JsParsable, JsArrayParsable {
  
  static let jsParsers: JsParseTransformSet<Self> = try! .init([
    ([".p", ".d"], {
      let path = try $0.path(0)
      let obj = try $0.obj(1)
      return .p(path, try? obj.int("b"), p: try? obj.int("p"), bits: nil, extra: [:], packIso: nil, try obj.xform())
    }),
  ], "general parm")
  
  func toJS() -> [String:Any?] {
    [
      "b" : b,
      "p" : p,
      "path" : path.toJS(),
    ]
  }
  
  static let jsArrayParsers: JsParseTransformSet<[Self]> = try! .init([
    (".a", {
      guard $0.arrCount() > 0 else { return [] }
      
      if (try? $0.path(0)) != nil {
        // if first element is a path, treat this as a Parm
        return [try $0.xform()]
      }
      else {
        // otherwise, treat it as a bunch of [Parm]s
        return try $0.map { try $0.xform() }.reduce([], +)
      }
    }),
    ([
      "prefix" : ".p",
      "count" : ".n",
      "bx" : ".n?",
      "px" : ".n?",
      "block" : ".x",
    ], {
      let block = try $0.any("block")
      return try .prefix(try $0.path("prefix"), count: try $0.int("count"), bx: (try? $0.int("bx")) ?? 0, px: try? $0.int("px"), block: {
        let parms: JSValue
        if block.isFn {
          guard let p = try block.call([$0]) else {
            throw JSError.error(msg: "Parms: prefix: block fn returned null")
          }
          parms = p
        }
        else {
          parms = block
        }
        return try parms.xform(jsArrayParsers)
      })
    }),
    ([
      "prefix" : ".p",
      "block" : ".x",
    ], {
      let parms: [Parm] = try $0.xform("block")
      return parms.prefix(try $0.path("prefix"))
    }),
    ([
      "inc" : ".n",
      "block" : ".x",
    ], {
      let parms: [Parm] = try $0.xform("block")
      return parms.inc(b: try? $0.int("b"), p: try? $0.int("p"), inc: try $0.int("inc"))
    }),
    ([
      "offset" : ".x",
    ], {
      let parms: [Parm] = try $0.xform("offset")
      return parms.offset(b: (try? $0.int("b")) ?? 0, p: try? $0.int("p"))
    }),
  ], "parms")
}

extension Parm.Span: JsParsable {
  
  static let jsParsers: JsParseTransformSet<Self> = try! .init([
    (["opts" : ".a"], { .opts(try $0.arrStr("opts")) }),
    (["max" : ".n"], { .max(try $0.int("max")) }),
    ([
      "rng" : ".a",
      "dispOff" : ".n?",
    ], {
      let rngArr = try $0.arr("rng")
      let min = try rngArr.int(0)
      let max = try rngArr.int(1) - 1
      return .rng(min...max, dispOff: (try? $0.int("dispOff")) ?? 0)
    }),
    (["options" : ".a"], { .options(try $0.arr("options").optDict()) }),
    ([:], { _ in .rng() }),
  ], "parm.span")
  
}
