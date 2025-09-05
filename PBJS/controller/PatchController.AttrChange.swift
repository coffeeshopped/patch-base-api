
import PBAPI
import JavaScriptCore

extension PatchController.AttrChange: JsParsable {
  
  static let nuJsRules: [NuJsParseRule<Self>] = [
    .a("dimItem", [Bool.self, SynthPath.self], optional: [CGFloat.self], {
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
    .a("dimPanel", [Bool.self], optional: [String.self, CGFloat.self], {
      try .dimPanel($0.x(1), $0.xq(2), dimAlpha: $0.xq(3))
    }),
    .a("hidePanel", [Bool.self], optional: [String.self], {
      try .dimPanel($0.x(1), $0.xq(2), dimAlpha: 0)
    }),
    .a("setValue", [SynthPath.self, Int.self], {
      try .setValue($0.x(1), $0.x(2))
    }),
    // TODO: Make this object-style
    .a("midiNote", [JsObj.self], {
      let obj = try $0.obj(1)
      return try .midiNote(chan: obj.x("ch"), note: obj.x("n"), velo: obj.x("v"), len: obj.x("l"))
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
    }),
    .t([JsObj].self, {
      // an Array is assumed to be [SynthPath:Int]
      try .paramsChange(.init($0.x()))
    }),
  ]
  
  // allow for a single AttrChange in places where an array is returned
  static var nuJsArrayRules: [NuJsParseRule<[Self]>] = [
    .arr([String.self], { [try $0.x()] }),
  ]

  
  static let jsRules: [JsParseRule<Self>] = [
    .a(["dimItem"], {
      try .dimItem($0.x(1), $0.x(2), dimAlpha: $0.xq(3))
    }),
    .a(["hideItem"], {
      try .dimItem($0.x(1), $0.x(2), dimAlpha: 0)
    }),
    .a(["setCtrlLabel", ".p", ".s"], {
      try .setCtrlLabel($0.x(1), $0.x(2))
    }),
    .a(["configCtrl", ".p", ".x"], {
      try .configCtrl($0.x(1), .span($0.x(2)))
    }),
    .a(["dimPanel", ".b", ".s?", ".n?"], {
      try .dimPanel($0.x(1), $0.xq(2), dimAlpha: $0.xq(3))
    }),
    .a(["hidePanel", ".b", ".s?"], {
      try .dimPanel($0.x(1), $0.xq(2), dimAlpha: 0)
    }),
    .a(["setValue", ".p", ".n"], {
      try .setValue($0.x(1), $0.x(2))
    }),
    .a(["midiNote", ".d"], {
      let obj = try $0.obj(1)
      return try .midiNote(chan: obj.x("ch"), note: obj.x("n"), velo: obj.x("v"), len: obj.x("l"))
    }),
    .a(["colorItem", ".p", ".n?", ".b?"], {
      try .colorItem($0.x(1), level: $0.xq(2) ?? 1, clearBG: $0.xq(3))
    }),
    .a(["setIndex", ".s?", ".n"], {
      try .setIndex($0.xq(1), $0.x(2))
    }),
    .a(["paramsChange", ".a"], {
      try .paramsChange(.init($0.x(1)))
    }),
    .a(["setNavPath", ".p", ".p?"], {
      try .setNavPath(id: $0.xq(2), $0.x(1))
    }),
    .a([".p", ".n"], {
      // TODO: see if this makes things funky with multiple paramsChange's being returned
      // ... leading to extra MIDI traffic.
      try .paramsChange(.init([$0.x(0) : $0.x(1)]))
    }),
    .s(".a", {
      // an Array is assumed to be [SynthPath:Int]
      try .paramsChange(.init($0.x()))
    }),
  ]

  // allow for a single AttrChange in places where an array is returned
  static var jsArrayRules: [JsParseRule<[PatchController.AttrChange]>] = [
    .a([".s"], { [try $0.x()] }),
  ]
}
