
import PBAPI
import JavaScriptCore

extension Parm: JsParsable, JsPassable {
  
  static let nuJsRules: [NuJsParseRule<Self>] = [
    .arr([SynthPath.self, JsObj.self], {
      let path: SynthPath = try $0.x(0)
      let obj = try $0.obj(1)
      var bits: ClosedRange<Int>? = try obj.xq("bits")
      if let bit = try obj.xq("bit") as Int? {
        bits = bit...bit
      }
      return try .p(path, obj.xq("b"), p: obj.xq("p"), bits: bits, extra: [:], packIso: obj.xq("packIso"), obj.x())
    }),
  ]
  
  static let nuJsArrayRules: [NuJsParseRule<[Self]>] = [
    .arr([JsObj.self], {
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
    .d([
      "prefix" : SynthPath.self,
      "count" : Int.self,
      "bx?" : Int.self,
      "px?" : Int.self,
      "block" : JsObj.self,
    ], {
      let block = try $0.any("block")
      let exportOrigin = $0.exportOrigin()
      return try .prefix($0.x("prefix"), count: $0.x("count"), bx: $0.xq("bx") ?? 0, px: $0.xq("px"), block: {
        let parms: JSValue
        guard block.isFn else { return try block.x() }
        guard let p = try block.call([$0], exportOrigin: exportOrigin) else {
          throw JSError.error(msg: "Parms: prefix: block fn returned null")
        }
        return try p.x()
      })
    }),
    .d([
      "prefix" : SynthPath.self,
      "block" : [Parm].self,
    ], {
      let parms: [Parm] = try $0.x("block")
      return parms.prefix(try $0.x("prefix"))
    }),
    .d([
      "inc" : Int.self,
      "block" : [Parm].self,
      "b?" : Int.self,
      "p?" : Int.self,
    ], {
      let parms: [Parm] = try $0.x("block")
      return try parms.inc(b: $0.xq("b"), p: $0.xq("p"), inc: $0.x("inc"))
    }),
    .d([
      "offset" : [Parm].self,
      "b?" : Int.self,
      "p?" : Int.self,
    ], {
      let parms: [Parm] = try $0.x("offset")
      return try parms.offset(b: $0.xq("b") ?? 0, p: $0.xq("p"))
    }),
    .d(["b2p" : [Parm].self], {
      let parms: [Parm] = try $0.x("b2p")
      return parms.b2p()
    }),
  ]
  
  static let jsRules: [JsParseRule<Self>] = [
    .a([".p", ".d"], {
      let path: SynthPath = try $0.x(0)
      let obj = try $0.obj(1)
      var bits: ClosedRange<Int>? = try obj.xq("bits")
      if let bit = try obj.xq("bit") as Int? {
        bits = bit...bit
      }
      return try .p(path, obj.xq("b"), p: obj.xq("p"), bits: bits, extra: [:], packIso: obj.xq("packIso"), obj.x())
    }),
  ]
  
  func toJS() -> AnyHashable {
    var d: [String:AnyHashable] = [
      "b" : b,
      "p" : p,
      "path" : path.toJS(),
    ]
    d.merge(span.jsDict()) { older, newer in newer }
    return d
  }
  
  static var jsArrayRules: [JsParseRule<[Parm]>] = [
    .s(".a", {
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
    .d([
      "prefix" : ".p",
      "count" : ".n",
      "bx" : ".n?",
      "px" : ".n?",
      "block" : ".x",
    ], {
      let block = try $0.any("block")
      let exportOrigin = $0.exportOrigin()
      return try .prefix($0.x("prefix"), count: $0.x("count"), bx: $0.xq("bx") ?? 0, px: $0.xq("px"), block: {
        let parms: JSValue
        guard block.isFn else { return try block.x() }
        guard let p = try block.call([$0], exportOrigin: exportOrigin) else {
          throw JSError.error(msg: "Parms: prefix: block fn returned null")
        }
        return try p.x()
      })
    }),
    .d([
      "prefix" : ".p",
      "block" : ".x",
    ], {
      let parms: [Parm] = try $0.x("block")
      return parms.prefix(try $0.x("prefix"))
    }),
    .d([
      "inc" : ".n",
      "block" : ".x",
    ], {
      let parms: [Parm] = try $0.x("block")
      return try parms.inc(b: $0.xq("b"), p: $0.xq("p"), inc: $0.x("inc"))
    }),
    .d([
      "offset" : ".x",
    ], {
      let parms: [Parm] = try $0.x("offset")
      return try parms.offset(b: $0.xq("b") ?? 0, p: $0.xq("p"))
    }),
    .d(["b2p" : ".x"], {
      let parms: [Parm] = try $0.x("b2p")
      return parms.b2p()
    }),
  ]
}

extension Parm.Span: JsParsable, JsPassable {
  
  static let nuJsRules: [NuJsParseRule<Self>] = [
    .d(["opts" : [JsObj].self], {
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
    .d([
      "iso" : IsoFS.self,
      "max" : Int.self,
    ], { try .isoS($0.x("iso"), range: 0...($0.x("max"))) }),
    .d([
      "max" : Int.self,
      "dispOff?" : Int.self,
    ], { try .max($0.x("max"), dispOff: $0.xq("dispOff") ?? 0) }),
    .d([
      "rng" : ClosedRange<Int>.self,
      "dispOff?" : Int.self,
    ], {
      return try .rng($0.x("rng"), dispOff: $0.xq("dispOff") ?? 0)
    }),
    .d([
      "dispOff" : Int.self,
    ], { try .rng(dispOff: $0.x("dispOff")) }),
    .d(["options" : [Int:String].self], { .options(try $0.x("options")) }),
    .d([
      "iso" : IsoFS.self,
      "rng?" : ClosedRange<Int>.self,
    ], {
      try .isoS($0.x("iso"), range: $0.xq("rng"))
    }),
    .t(JsObj.self, { _ in .rng() }),
  ]
  
  static let jsRules: [JsParseRule<Self>] = [
    .d(["opts" : ".a"], {
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
    .d([
      "iso" : ".x",
      "max" : ".n",
    ], { try .isoS($0.x("iso"), range: 0...($0.x("max"))) }),
    .d([
      "max" : ".n",
      "dispOff" : ".n?",
    ], { try .max($0.x("max"), dispOff: $0.xq("dispOff") ?? 0) }),
    .d([
      "rng" : ".a",
      "dispOff" : ".n?",
    ], {
      let rngArr = try $0.arr("rng")
      let min: Int = try rngArr.x(0)
      let max: Int = try rngArr.x(1) - 1
      return try .rng(min...max, dispOff: $0.xq("dispOff") ?? 0)
    }),
    .d([
      "dispOff" : ".n",
    ], { try .rng(dispOff: $0.x("dispOff")) }),
    .d(["options" : ".a"], { .options(try $0.arr("options").optDict()) }),
    .d([
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
    .d([:], { _ in .rng() }),
  ]
  
  func toJS() -> AnyHashable { jsDict() }
  
  fileprivate func jsDict() -> [String:AnyHashable] {
    switch self {
    case .options(let opts):
      // create a sparse array.
      let max = (opts.keys.max() ?? 0) + 1
      var out = [String?](repeating: nil, count: max)
      opts.forEach { out[$0.key] = $0.value }
      return [
        "opts" : out,
      ]
    case .rng(let range, let dispOff):
      return [
        "range" : [range?.lowerBound ?? 0, range?.upperBound ?? 127],
        "dispOff" : dispOff,
      ] as [String:AnyHashable]
    default:
      return ["error": "ERROR"]
    }
  }
}
