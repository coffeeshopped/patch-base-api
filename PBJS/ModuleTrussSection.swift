
import PBAPI

extension ModuleTrussSection: JsParsable, JsArrayParsable {
  
  static let jsParsers: JsParseTransformSet<Self> = try! .init([
    (["first", ".a"], { .first(try $0.xform(1)) }),
    (["basic", ".s", ".a"], { .basic(try $0.str(1), try $0.xform(2)) }),
    (["banks", ".a"], { .banks(try $0.xform(1)) }),
  ], "section")

  static let jsArrayParsers = try! jsParsers.arrayParsers()
}

extension ModuleTrussSection.Item: JsParsable, JsArrayParsable {

  static let jsParsers: JsParseTransformSet<Self> = try! .init([
    (["global", ".d", ".s?"], { .global(try $0.xform(1), title: try? $0.str(2)) }),
    (["voice", ".s", ".d"], { .voice(try $0.str(1), path: nil, try $0.xform(2)) }),
    (["bank", ".s", ".p"], { .bank(try $0.str(1), try $0.path(2)) }),
    ("channel", { _ in .channel() } ),
  ], "section item")

  static let jsArrayParsers = try! jsParsers.arrayParsers()

}
