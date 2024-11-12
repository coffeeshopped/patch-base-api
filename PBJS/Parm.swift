
import PBAPI
import JavaScriptCore

extension Parm: JsParsable, JsArrayParsable, JsPassable {
  
  static let jsParsers: JsParseTransformSet<Self> = try! .init([
    ([".p", ".d"], {
      let path: SynthPath = try $0.x(0)
      let obj = try $0.obj(1)
      return try .p(path, obj.xq("b"), p: obj.xq("p"), bits: nil, extra: [:], packIso: obj.xq("packIso"), obj.x())
    }),
  ], "general parm")
  
  func toJS() -> Any {
    [
      "b" : b as Any,
      "p" : p as Any,
      "path" : path.toJS(),
    ]
  }
  
  static let jsArrayParsers: JsParseTransformSet<[Self]> = try! .init([
    (".a", {
      guard $0.arrCount() > 0 else { return [] }
      
      if (try? $0.x(0) as SynthPath) != nil {
        // if first element is a path, treat this as a Parm
        return [try $0.x() as Parm]
      }
      else {
        // otherwise, treat it as a bunch of [Parm]s
        return try $0.map { try $0.x() }.reduce([], +)
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
      return try .prefix($0.x("prefix"), count: $0.x("count"), bx: $0.xq("bx") ?? 0, px: $0.xq("px"), block: {
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
      let parms: [Parm] = try $0.x("block")
      return parms.prefix(try $0.x("prefix"))
    }),
    ([
      "inc" : ".n",
      "block" : ".x",
    ], {
      let parms: [Parm] = try $0.x("block")
      return try parms.inc(b: $0.xq("b"), p: $0.xq("p"), inc: $0.x("inc"))
    }),
    ([
      "offset" : ".x",
    ], {
      let parms: [Parm] = try $0.x("offset")
      return try parms.offset(b: $0.xq("b") ?? 0, p: $0.xq("p"))
    }),
    (["b2p" : ".x"], {
      let parms: [Parm] = try $0.x("b2p")
      return parms.b2p()
    }),
    
  ], "parms")
}

extension Parm.Span: JsParsable {
  
  static let jsParsers: JsParseTransformSet<Self> = try! .init([
    (["opts" : ".a"], {
      // allow for sparse arrays.
      // TODO: follow up and see if this causes weirdness with controls.
      let arr = try $0.arr("opts")
      let count = arr.arrCount()
      var options = [Int:String]()
      count.forEach {
        guard let v = arr.atIndex($0),
              !v.isUndefined else { return }
        options[$0] = v.toString()
      }
      return .options(options)
//      return .opts(try $0.arrStr("opts"))
    }),
    ([
      "max" : ".n",
      "dispOff" : ".n?",
    ], { try .max($0.x("max"), dispOff: $0.xq("dispOff") ?? 0) }),
    ([
      "rng" : ".a",
      "dispOff" : ".n?",
    ], {
      let rngArr = try $0.arr("rng")
      let min: Int = try rngArr.x(0)
      let max: Int = try rngArr.x(1) - 1
      return try .rng(min...max, dispOff: $0.xq("dispOff") ?? 0)
    }),
    (["options" : ".a"], { .options(try $0.arr("options").optDict()) }),
    ([
      "iso" : ".x",
      "rng" : ".a?",
    ], {
      var range: ClosedRange<Int>? = nil
      if let rngArr = try? $0.arr("rng") {
        let min: Int = try rngArr.x(0)
        let max: Int = try rngArr.x(1) - 1
        range = min...max
      }
      return try .isoS($0.x("iso"), range: range)
    }),
    ([:], { _ in .rng() }),
  ])
  
}
