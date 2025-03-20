
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
      return try .perf(title: title, path: path, $0.x(1))
    }),
    (["bank", ".s", ".p"], { try .bank($0.x(1), $0.x(2)) }),
    ("channel", { _ in .channel() } ),
    ("deviceId", { _ in .deviceId() }),
    (["custom", ".s", ".p", ".d"], {
      try .custom($0.x(1), $0.x(2), $0.x(3))
    }),
  ])

  static let jsArrayParsers: JsParseTransformSet<[Self]> = try! jsParsers.arrayParsers([
    (["perfParts", ".n", ".f", ".x"], {
      try .perfParts($0.x(1), $0.fn(2), pathPrefix: [.part], $0.x(3))
    }),
    (["banks", ".n", ".f", ".p"], {
      try .banks($0.x(1), $0.fn(2), $0.x(3))
    }),
  ])

}
