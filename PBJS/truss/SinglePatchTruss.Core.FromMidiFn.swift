import PBAPI
import JavaScriptCore

extension SysexTrussCore.FromMidiFn : JsParsable {

  // see SysexTrussCore.ToMidiFn (JsParsable impl)
  static var nuJsRules: [NuJsParseRule<Self>] {
    switch BodyData.self {
    case is [UInt8].Type:
      return SysexTrussCore<[UInt8]>.FromMidiFn.nuJsRules as! [NuJsParseRule<Self>]
//    case is [SynthPath:[UInt8]].Type:
//      return SysexTrussCore<[SynthPath:[UInt8]]>.ToMidiFn.jsRules as! [JsParseRule<Self>]
//    case is [[UInt8]].Type:
//      return SomeBankTruss<SinglePatchTruss>.bankToMidiRules as! [JsParseRule<Self>]
//    case is [[SynthPath:[UInt8]]].Type:
//      return SomeBankTruss<MultiPatchTruss>.bankToMidiRules as! [JsParseRule<Self>]
    default:
      fatalError("Unimplemented JsParsable")
    }
  }

  

}

extension SysexTrussCore<[UInt8]>.FromMidiFn {
  
  static func chainRule(_ v: JSValue) throws -> Self {
    // v is a JS array. Skip the first element.
    // the second element is a FromMidiFn.
    // the rest, treat as an array of ByteTransforms, with the output of each function being fed as input to the next function.
    let count = v.arrCount()
    let mfn: Self = try v.x(1)
    let fns: [ByteTransform] = try (2..<(count-1)).map { try v.x($0) }
    return .fn { msgs in
      let b = try mfn.call(msgs)
      return try fns.reduce(b) { partialResult, fn in try fn.call(partialResult, nil) }
    }
  }

  static let nuJsRules: [NuJsParseRule<Self>] = [
    .a(">", [SinglePatchTruss.Core.FromMidiFn.self, ByteTransform.self], {
      try chainRule($0)
    }),
    .arr([JsObj.self], {
      // first see if it's a byte transform
      if let bt = try? $0.x() as ByteTransform {
        return .fn { msgs in
          try bt.call(msgs.flatMap { $0.bytes() }, nil)
        }
      }

      // otherwise, treat as an implicit "+"
      let fns: [Self] = try $0.map { try $0.x() }
      return .fn({ b in try fns.flatMap { try $0.call(b) } })
    }),
//    .s(".f", { fn in
//      try fn.checkFn()
//      return .fn({ try fn.call([$0], exportOrigin: nil).x() })
//    }),
  ]
  
  static let jsRules: [JsParseRule<Self>] = [
    .a([">"], {
      try chainRule($0)
    }),
    .s(".a", {
      // first see if it's a byte transform
      if let bt = try? $0.x() as ByteTransform {
        return .fn { msgs in
          try bt.call(msgs.flatMap { $0.bytes() }, nil)
        }
      }

      // otherwise, treat as an implicit "+"
      let fns: [Self] = try $0.map { try $0.x() }
      return .fn({ b in try fns.flatMap { try $0.call(b) } })
    }),
//    .s(".f", { fn in
//      try fn.checkFn()
//      return .fn({ try fn.call([$0], exportOrigin: nil).x() })
//    }),
  ]}
