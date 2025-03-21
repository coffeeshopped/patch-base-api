
import PBAPI

extension JSONPatchTruss {
  
  static let jsRules: [JsParseRule<Self>] = [
    .d([
      "type" : "json",
      "id" : ".s",
      "parms" : ".a",
    ], {
      return try .init($0.x("id"), parms: $0.x("parms"))
    }),
    .s("channel", ChannelSettingsTruss),
  ]

}
