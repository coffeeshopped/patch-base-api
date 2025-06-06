
import PBAPI

extension PatchController.Effect: JsParsable {
  
  static let jsRules: [JsParseRule<Self>] = [
    .a(["editMenu", ".p", ".d"], {
      let config = try $0.obj(2)
      // paths can be an [SynthPath], or [Parm].
      let paths: [SynthPath]
      if let p = try? config.x("paths") as [SynthPath] {
        paths = p
      }
      else {
        let p: [Parm] = try config.x("paths")
        paths = p.map { $0.path }
      }
      return try .editMenu($0.xq(1), paths: paths, type: config.x("type"), init: config.xq("init"), rand: nil, items: [])
    }),
    .a(["patchChange", ".p", ".f"], {
      try .patchChange($0.x(1), $0.fn(2))
    }),
    .a(["patchChange", ".d"], {
      let config = try $0.obj(1)
      let fn = try config.fn("fn")
      return .patchChange(paths: try config.x("paths")) { values in
        var v = [String:Int]()
        values.forEach { v[$0.str()] = $1 }
        return try fn.call([v], exportOrigin: nil).x()
      }
    }),
    .a(["dimsOn", ".p", ".s?", ".d?"], {
      let obj = try? $0.obj(3)
      var f: ((Int) throws -> Bool)? = nil
      if let fn = try? obj?.fn("dimWhen") {
        f = { try fn.call([$0], exportOrigin: nil).x() }
      }
      return try .dimsOn($0.x(1), id: $0.xq(2), dimAlpha: obj?.xq("dimAlpha"), dimWhen: f)
    }),
    .a(["dimsOn", ".d", ".s?"], {
      let obj = try $0.obj(1)
      return try .dimsOn(obj.x("paths"), id: $0.xq(2))
    }),
    .a(["indexChange", ".f"], {
      try .indexChange($0.fn(1))
    }),
    .a(["paramChange", ".p", ".f"], {
      try .paramChange($0.x(1), $0.fn(2))
    }),
    .a (["controlChange", ".p", ".f"], {
      try .controlChange($0.x(1), fn: $0.fn(2))
    }),
    .a(["setup", ".a"], { .setup(try $0.x(1)) }),
    .a(["basicControlChange", ".p"], { try .basicControlChange($0.x(1)) }),
    .a(["basicPatchChange", ".p"], { try .basicPatchChange($0.x(1)) }),
    .a(["click", ".p?", ".f"], { try .click($0.xq(1), $0.fn(2)) }),
    .a(["listen", ".p", ".f"], { try .listen($0.x(1), $0.fn(2)) }),
  ]
  
  static var jsArrayRules: [JsParseRule<[PatchController.Effect]>] = [
    .a(["voiceReserve", ".a", ".n", ".a"], {
      try .voiceReserve(paths: $0.x(1), total: $0.x(2), ctrls: $0.x(3))
    }),
    .a(["ctrlBlocks", ".p", ".d?"], {
      let obj = try? $0.obj(2)
      return try .ctrlBlocks($0.x(1), value: nil, cc: nil, param: obj?.xq("parm"))
    }),
    .a(["patchSelector", ".p", ".d"], {
      let obj = try $0.obj(2)
      if let fn = try? obj.fn("paramMapWithContext") {
        return try .patchSelector(id: $0.x(1), bankValues: obj.x("bankValues"), paramMapWithContext: obj.fn("paramMapWithContext"))
      }
      else {
        if let bankValues = try? obj.x("bankValues") as [SynthPath] {
          return try .patchSelector(id: $0.x(1), bankValues: bankValues, paramMap: obj.fn("paramMap"))
        }
        else {
          return try .patchSelector(id: $0.x(1), bankValue: obj.x("bankValue"), paramMap: obj.fn("paramMap"))
        }
      }
    }),
    .a([".s"], { [try $0.x()] }),
  ]
}

