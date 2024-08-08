
import PBAPI

extension EditorValueTransform : JsParsable, JsArrayParsable {
  
  static let jsParsers: JsParseTransformSet<Self> = try! .init([
    ([
      "type" : "value",
      "editorPath" : ".p",
      "patchPath" : ".p",
    ], {
      return .value(try $0.path("editorPath"), try $0.path("patchPath"), defaultValue: 0)
    }),
    ("basic", { _ in .basicChannel }),
  ], "editor Value Transform")

  static let jsArrayParsers = try! jsParsers.arrayParsers()

}
