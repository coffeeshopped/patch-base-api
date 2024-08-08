
import PBAPI
import JavaScriptCore

extension FetchTransform: JsParsable, JsArrayParsable {
  
  static let jsParsers: JsParseTransformSet<Self> = try! .init([
    ([
      "sequence" : ".a",
    ], { .sequence(try $0.xform("sequence")) }),
    ([
      "truss" : ".f",
    ], {
      let fn = try $0.fn("truss")
      return .truss(try? $0.xform("editorVal")) { try fn.call([$0]).arrByte() }
    }),
    ([
      "custom" : ".f",
    ], {
      let fn = try $0.fn("custom")
      let editorVals: [EditorValueTransform] = (try? $0.xform("editorVals")) ?? []
      return .custom(editorVals) { values, path in
        // transform the dictionary to an array based on the order they were specified
        let valArr = editorVals.map { values[$0] }
        return try fn.call([valArr, path]).xform()
      }
    }),
    ([
      "bankTruss" : ".f",
    ], {
      let fn = try $0.fn("bankTruss")
      return .bankTruss(try? $0.xform("editorVal"), { value, location in
        try fn.call([value, location]).arrByte()
      }, waitInterval: 0)
    })
  ], "fetch Transform")
  
  static let jsArrayParsers = try! jsParsers.arrayParsers()
  
}
