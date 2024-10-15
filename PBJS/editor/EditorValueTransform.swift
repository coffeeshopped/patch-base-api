
import PBAPI

extension EditorValueTransform : JsParsable, JsArrayParsable {
  
  static let jsParsers: JsParseTransformSet<Self> = try! .init([
    (["e", ".p", ".p", ".n?"], {
      try .value($0.x(1), $0.x(2), defaultValue: $0.xq(3) ?? 0)
    }), // returns editorValue
    ("channel", { _ in .basicChannel }),
  ], "editor Value Transform")

  static let jsArrayParsers = try! jsParsers.arrayParsers()

}
