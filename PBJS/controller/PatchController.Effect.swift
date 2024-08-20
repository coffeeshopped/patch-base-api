
import PBAPI

extension PatchController.Effect: JsParsable, JsArrayParsable {
  
  static let jsParsers: JsParseTransformSet<Self> = try! .init([
    (["editMenu", ".p", ".d"], {
      let config = try $0.obj(2)
      let paths = try config.arrPath("paths")
      let innit = try? config.arrInt("init")
      return try .editMenu($0.xq(1), paths: paths, type: config.x("type"), init: innit, rand: nil, items: [])
    }),
    (["patchChange", ".p", ".f"], {
      let fn = try $0.fn(2)
      return .patchChange(try $0.x(1)) { v in
        try fn.call([v]).x()
      }
    }),
    (["patchChange", ".d"], {
      let config = try $0.obj(1)
      let paths = try config.arrPath("paths")
      let fn = try config.fn("fn")
      return .patchChange(paths: paths) { values in
        try fn.call([paths.map { values[$0]! }]).x()
      }
    }),
    (["dimsOn", ".p"], {
      return .dimsOn(try $0.x(1), id: nil, dimAlpha: nil, dimWhen: nil)
    }),
    (["indexChange", ".f"], {
      let fn = try $0.fn(1)
      return .indexChange { try fn.call([$0]).x() }
    }),
    (["paramChange", ".p", ".f"], {
      let fn = try $0.fn(2)
      return .paramChange(try $0.x(1)) { parm in
        try fn.call([parm]).x()
      }
    }),
    (["controlChange", ".p", ".f"], {
      let fn = try $0.fn(2)
      return .controlChange(try $0.x(1)) { state, locals in
        try fn.call([state, locals]).x()
      }
    }),
    (["setup", ".a"], { .setup(try $0.x(1)) })
  ])
  
  static let jsArrayParsers: JsParseTransformSet<[Self]> = try! .init([
    (["voiceReserve", ".a", ".n", ".a"], {
      try .voiceReserve(paths: $0.arrPath(1), total: $0.x(2), ctrls: $0.arrPath(3))
    }),
    (".a", {
      // TODO: this should probably be the implementation of jsArrayParsers()
      guard $0.arrCount() > 0 else { return [] }
      return try $0.map {
        guard let x = try? $0.xform(jsParsers) else {
          return try $0.x()
        }
        return [x]
      }.reduce([], +)
    }),
  ])
}

