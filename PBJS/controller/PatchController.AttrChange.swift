
import PBAPI
import JavaScriptCore

extension PatchController.AttrChange: JsParsable {
  
  public static let jsRules: [JsParseRule<Self>] = [
    .a("dimItem", [Bool.self, SynthPath.self], optional: [Float.self], {
      try .dimItem($0.x(1), $0.x(2), dimAlpha: $0.xq(3))
    }),
    .a("hideItem", [Bool.self, SynthPath.self], {
      try .dimItem($0.x(1), $0.x(2), dimAlpha: 0)
    }),
    .a("setCtrlLabel", [SynthPath.self, String.self], {
      try .setCtrlLabel($0.x(1), $0.x(2))
    }),
    .a("configCtrl", [SynthPath.self, Parm.Span.self], {
      try .configCtrl($0.x(1), .span($0.x(2)))
    }),
    .a("dimPanel", [Bool.self], optional: [String.self, Float.self], {
      try .dimPanel($0.x(1), $0.xq(2), dimAlpha: $0.xq(3))
    }),
    .a("hidePanel", [Bool.self], optional: [String.self], {
      try .dimPanel($0.x(1), $0.xq(2), dimAlpha: 0)
    }),
    .a("setValue", [SynthPath.self, Int.self], {
      try .setValue($0.x(1), $0.x(2))
    }),
    // TODO: Make this object-style
    .a("midiNote", [UInt8.self, UInt8.self, UInt8.self, Int.self], {
      let obj = try $0.obj(1)
      return try .midiNote(chan: obj.x(1), note: obj.x(2), velo: obj.x(3), len: obj.x(4))
    }),
    .a("colorItem", [SynthPath.self], optional: [Int.self, Bool.self], {
      try .colorItem($0.x(1), level: $0.xq(2) ?? 1, clearBG: $0.xq(3))
    }),
    .a("setIndex", [Int.self], optional: [String.self], {
      try .setIndex($0.xq(2), $0.x(1))
    }),
    .a("paramsChange", [[SynthPath:Int].self], {
      try .paramsChange(.init($0.x(1)))
    }),
    .a("setNavPath", [SynthPath.self], optional: [SynthPath.self], {
      try .setNavPath(id: $0.xq(2), $0.x(1))
    }),
    .arr([SynthPath.self, Int.self], {
      // TODO: see if this makes things funky with multiple paramsChange's being returned
      // ... leading to extra MIDI traffic.
      try .paramsChange(.init([$0.x(0) : $0.x(1)]))
    }, "basicParamsChange"),
    .t([SynthPath:Int].self, {
      // an Array is assumed to be [SynthPath:Int]
      try .paramsChange(.init($0.x()))
    }),
  ]
  
  // allow for a single AttrChange in places where an array is returned
  public static var jsArrayRules: [JsParseRule<[Self]>] = [
    .arr([String.self], { [try $0.x()] }, "single"),
  ]
  
}
