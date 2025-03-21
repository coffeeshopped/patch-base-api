
import PBAPI

extension PatchController.PageSetup: JsParsable {
  
  static let jsRules: [JsParseRule<Self>] = [
    .a(["map", ".a", ".a"], {
      try .map($0.x(1), $0.x(2))
    }),
    .a(["controllers", ".a"], {
      try .controllers($0.x(1))
    }),
  ]

}
