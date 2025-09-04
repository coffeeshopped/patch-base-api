
import PBAPI

extension JSONPatchTruss {
  
  static let nuJsRules: [NuJsParseRule<Self>] = [
    .d([
      "json" : String.self,
      "parms" : [Parm].self,
    ], {
      return try .init($0.x("json"), parms: $0.x("parms"))
    }),
    .s("channel", ChannelSettingsTruss),
  ]
  
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
