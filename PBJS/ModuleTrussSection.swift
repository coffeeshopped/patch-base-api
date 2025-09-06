
import PBAPI

extension ModuleTrussSection: JsParsable {
  
  public static let jsRules: [JsParseRule<Self>] = [
    .a("first", [[Item].self], { .first(try $0.x(1)) }),
    .a("basic", [String.self, [Item].self], { try .basic($0.x(1), $0.x(2)) }),
    .a("banks", [[Item].self], { .banks(try $0.x(1)) }),
  ]
  
}

extension ModuleTrussSection.Item: JsParsable {
  
  public static let jsRules: [JsParseRule<Self>] = [
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

  public static let jsArrayRules: [JsParseRule<[Self]>] = [
    .a("perfParts", [Int.self, JsFn.self, PatchController.self], {
      try .perfParts($0.x(1), $0.fn(2), pathPrefix: [.part], $0.x(3))
    }),
    .a("banks", [Int.self, JsFn.self, PatchController.self], {
      try .banks($0.x(1), $0.fn(2), $0.x(3))
    }),
  ]

}
