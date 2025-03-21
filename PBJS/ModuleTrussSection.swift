
import PBAPI

extension ModuleTrussSection: JsParsable {
  
  static let jsRules: [JsParseRule<Self>] = [
    .a(["first", ".a"], { .first(try $0.x(1)) }),
    .a(["basic", ".s", ".a"], { .basic(try $0.x(1), try $0.x(2)) }),
    .a(["banks", ".a"], { .banks(try $0.x(1)) }),
  ]

}

extension ModuleTrussSection.Item: JsParsable {

  static let jsRules: [JsParseRule<Self>] = [
    .a(["global", ".d", ".s?"], { try .global($0.x(1), title: $0.xq(2)) }),
    .a(["voice", ".s", ".d", ".p?"], {
      try .voice($0.x(1), path: $0.xq(3), $0.x(2))
    }),
    .a(["perf", ".d"], {
      let config = try? $0.obj(2)
      let title = try config?.xq("title") ?? "Performance"
      let path: SynthPath = try config?.xq("path") ?? [.perf]
      return try .perf(title: title, path: path, $0.x(1))
    }),
    .a(["bank", ".s", ".p"], { try .bank($0.x(1), $0.x(2)) }),
    .s("channel", .channel()),
    .s("deviceId", .deviceId()),
    .a(["custom", ".s", ".p", ".d"], {
      try .custom($0.x(1), $0.x(2), $0.x(3))
    }),
  ]
  
  static let jsArrayRules: [JsParseRule<[Self]>] = [
    .a(["perfParts", ".n", ".f", ".x"], {
      try .perfParts($0.x(1), $0.fn(2), pathPrefix: [.part], $0.x(3))
    }),
    .a(["banks", ".n", ".f", ".p"], {
      try .banks($0.x(1), $0.fn(2), $0.x(3))
    }),
  ]

}
