
import PBAPI

extension JSONPatchTruss {
  
  static let jsRules: [JsParseRule<Self>] = [
    .d([
      "json" : ".s",
      "parms" : ".a",
    ], {
      return try .init($0.x("json"), parms: $0.x("parms"))
    }),
    .s("channel", ChannelSettingsTruss),
  ]

}
