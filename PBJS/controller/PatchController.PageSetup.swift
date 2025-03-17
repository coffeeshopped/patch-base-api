
import PBAPI

extension PatchController.PageSetup: JsParsable {
  
  static let jsParsers: JsParseTransformSet<Self> = try! .init([
    (["map", ".a", ".a"], {
      try .map($0.x(1), $0.x(2))
    }),
    (["controllers", ".a"], {
      try .controllers($0.x(1))
    }),
  ])

}
