
import PBAPI

extension ModuleTrussSection: JsParsable {
  
  static let nuJsRules: [NuJsParseRule<Self>] = [
    .a("first", [[Item].self], { .first(try $0.x(1)) }),
    .a("basic", [String.self, [Item].self], { try .basic($0.x(1), $0.x(2)) }),
    .a("banks", [[Item].self], { .banks(try $0.x(1)) }),
  ]
  
  static let jsRules: [JsParseRule<Self>] = [
    .a(["first", ".a"], { .first(try $0.x(1)) }),
    .a(["basic", ".s", ".a"], { try .basic($0.x(1), $0.x(2)) }),
    .a(["banks", ".a"], { .banks(try $0.x(1)) }),
  ]

}

extension ModuleTrussSection.Item: JsParsable {
  
  static let nuJsRules: [NuJsParseRule<Self>] = [
    .a("global", [PatchController.self], optional: [String.self], { try .global($0.x(1), title: $0.xq(2)) }),
    .a("voice", [String.self, PatchController.self], optional: [SynthPath.self], {
      try .voice($0.x(1), path: $0.xq(3), $0.x(2))
    }),
    .a("perf", [PatchController.self], optional: [JsObj.self], {
      let config = try? $0.obj(2)
      let title = try config?.xq("title") ?? "Performance"
      let path: SynthPath = try config?.xq("path") ?? [.perf]
      return try .perf(title: title, path: path, $0.x(1))
    }),
    .a("bank", [String.self, SynthPath.self], { try .bank($0.x(1), $0.x(2)) }),
    .s("channel", .channel()),
    .s("deviceId", .deviceId()),
    .a("custom", [String.self, SynthPath.self, PatchController.self], {
      try .custom($0.x(1), $0.x(2), $0.x(3))
    }),
  ]

  static let nuJsArrayRules: [NuJsParseRule<[Self]>] = [
    .a("perfParts", [Int.self, JsFn.self, PatchController.self], {
      try .perfParts($0.x(1), $0.fn(2), pathPrefix: [.part], $0.x(3))
    }),
    .a("banks", [Int.self, JsFn.self, PatchController.self], {
      try .banks($0.x(1), $0.fn(2), $0.x(3))
    }),
  ]
  
  static let jsRules: [JsParseRule<Self>] = [
    .a(["global", ".d", ".s?"], { try .global($0.x(1), title: $0.xq(2)) }),
    .a(["voice", ".s", ".d", ".p?"], {
      try .voice($0.x(1), path: $0.xq(3), $0.x(2))
    }),
    .a(["perf", ".d", ".d?"], {
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
