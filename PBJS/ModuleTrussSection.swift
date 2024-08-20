
import PBAPI

extension ModuleTrussSection: JsParsable, JsArrayParsable {
  
  static let jsParsers: JsParseTransformSet<Self> = try! .init([
    (["first", ".a"], { .first(try $0.x(1)) }),
    (["basic", ".s", ".a"], { .basic(try $0.x(1), try $0.x(2)) }),
    (["banks", ".a"], { .banks(try $0.x(1)) }),
  ])

  static let jsArrayParsers = try! jsParsers.arrayParsers()
}

extension ModuleTrussSection.Item: JsParsable, JsArrayParsable {

  static let jsParsers: JsParseTransformSet<Self> = try! .init([
    (["global", ".d", ".s?"], { .global(try $0.x(1), title: try $0.xq(2)) }),
    (["voice", ".s", ".d", ".p?"], {
      try .voice($0.x(1), path: $0.xq(3), $0.x(2))
    }),
    (["perf", ".d"], {
      let config = try? $0.obj(2)
      let title = try config?.xq("title") ?? "Performance"
      let path: SynthPath = try config?.xq("path") ?? [.perf]
      return .perf(title: title, path: path, try $0.x(1))
    }),
    (["bank", ".s", ".p"], { .bank(try $0.x(1), try $0.x(2)) }),
    ("channel", { _ in .channel() } ),
  ])

  static let jsArrayParsers = try! jsParsers.arrayParsers()

}
