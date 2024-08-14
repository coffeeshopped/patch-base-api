
import PBAPI

extension PatchController.Effect: JsParsable, JsArrayParsable {
  
  static let jsParsers: JsParseTransformSet<Self> = try! .init([
    (["editMenu", ".p", ".d"], {
      let config = try $0.obj(2)
      let paths = try config.arrPath("paths")
      let innit = try? config.arrInt("init")
      return .editMenu(try $0.xform(1), paths: paths, type: try config.str("type"), init: innit, rand: nil, items: [])
    }),
    (["patchChange", ".p", ".f"], {
      let fn = try $0.fn(2)
      return .patchChange(try $0.xform(1)) { v in
        try fn.call([v]).xform()
      }
    }),
    (["patchChange", ".d"], {
      let config = try $0.obj(1)
      let paths = try config.arrPath("paths")
      let fn = try config.fn("fn")
      return .patchChange(paths: paths) { values in
        try fn.call([paths.map { values[$0]! }]).xform()
      }
    }),
    (["dimsOn", ".p"], {
      return .dimsOn(try $0.path(1), id: nil, dimAlpha: nil, dimWhen: nil)
    })
  ], "PatchController.Effect")
  
  static let jsArrayParsers = try! jsParsers.arrayParsers()
}

