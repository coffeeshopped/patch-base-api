
import PBAPI

extension PatchController.PageSetup: JsParsable {

  public static let jsRules: [JsParseRule<Self>] = [
    .a("map", [[SynthPath].self, [SynthPath:PatchController].self], {
      try .map($0.x(1), $0.x(2))
    }),
    .a("controllers", [[PatchController].self], {
      try .controllers($0.x(1))
    }),
  ]

}
