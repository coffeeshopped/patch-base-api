
import PBAPI

extension PatchController.PageSetup: JsParsable {
  
  static let jsParsers: JsParseTransformSet<Self> = try! .init([
    (["map", ".a", ".a"], {
      try .map($0.arrPath(1), $0.x(2))
    }),
  ])

}
