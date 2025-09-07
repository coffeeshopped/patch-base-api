
import PBAPI

extension JSONPatchTruss : JsParsable {
  
  public static let jsRules: [JsParseRule<Self>] = [
    .d([
      "json" : String.self,
      "parms" : [Parm].self,
    ], {
      return try .init($0.x("json"), parms: $0.x("parms"))
    }, "basic"),
    .s("channel", ChannelSettingsTruss),
  ]
  
}
