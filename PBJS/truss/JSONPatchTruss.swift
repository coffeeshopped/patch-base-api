
import PBAPI

extension JSONPatchTruss {
  
  static let jsParsers: JsParseTransformSet<Self> = try! .init([
    ([
      "type" : "json",
      "id" : ".s",
      "parms" : ".a",
    ], {
      let parms = try $0.arr("parms").xform([Parm].jsParsers)
      return .init(try $0.str("id"), parms: parms)
    }),
    ("channel", { _ in ChannelSettingsTruss }),
  ], "JSONPatchTruss")

}
