
import PBAPI
import JavaScriptCore

extension FetchTransform: JsParsable {
  
  public static let jsRules: [JsParseRule<Self>] = [
    .a("sequence", [[FetchTransform].self], { .sequence(try $0.x(1)) }),
    .a("truss", [SinglePatchTruss.Core.ToMidiFn.self], {
      try .truss($0.x(1))
    }),
    .a("bankTruss", [SinglePatchTruss.Core.ToMidiFn.self], {
      // TODO: add bytesPerPatch and waitInterval
      try .bankTruss($0.x(1), bytesPerPatch: nil, waitInterval: 0)
    }),
    .a("send", [SinglePatchTruss.Core.ToMidiFn.self], {
      let fn: SinglePatchTruss.Core.ToMidiFn = try $0.x(1)
      return .custom({ e in
        try fn.call([], e).map { .sendMsg($0) }
      })
    }),
  ]
  
}
