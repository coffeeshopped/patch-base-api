
import PBAPI

extension JSONPatchTruss {
  
  static let jsRules: [JsParseRule<Self>] = [
    ([
      "type" : "json",
      "id" : ".s",
      "parms" : ".a",
    ], {
      let parms = try $0.arr("parms").xform([Parm].jsParsers)
      return .init(try $0.x("id"), parms: parms)
    }),
    ("channel", { _ in ChannelSettingsTruss }),
  ], "JSONPatchTruss")

}
