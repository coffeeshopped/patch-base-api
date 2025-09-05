
import PBAPI
import JavaScriptCore

extension FetchTransform: JsParsable {
  
  static let nuJsRules: [NuJsParseRule<Self>] = [
    .a("sequence", [[FetchTransform].self], { .sequence(try $0.x(1)) }),
    .a("truss", [SinglePatchTruss.Core.ToMidiFn.self], {
      try .truss($0.x(1))
    }),
    .a("bankTruss", [SinglePatchTruss.Core.ToMidiFn.self], {
      // TODO: add bytesPerPatch and waitInterval
      try .bankTruss($0.x(1), bytesPerPatch: nil, waitInterval: 0)
    }),
    .a("custom", [JsFn.self], {
      let fns = try $0.any(1).map {
        try $0.xform(RxMidi.FetchCommand.dynamicRules)
      }
      return .custom({ editor in try fns.map { try $0(editor) } })
    }),
  ]
  
//  static let jsRules: [JsParseRule<Self>] = [
//    .a(["sequence", ".x",], { .sequence(try $0.x(1)) }),
//    .a(["truss", ".x"], {
//      try .truss($0.x(1))
//    }),
//    .a(["bankTruss", ".x"], {
//      // TODO: add bytesPerPatch and waitInterval
//      try .bankTruss($0.x(1), bytesPerPatch: nil, waitInterval: 0)
//    }),
//    .a(["custom", ".x"], {
//      let fns = try $0.any(1).map {
//        try $0.xform(RxMidi.FetchCommand.dynamicRules)
//      }
//      return .custom({ editor in try fns.map { try $0(editor) } })
//    }),
//  ]
    
}
