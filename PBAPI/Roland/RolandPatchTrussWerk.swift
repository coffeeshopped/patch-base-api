
public protocol RolandPatchTrussWerk {

//  var werk: RolandSysexTrussWerk { get }
//  var start: RolandAddress { get }
  var size: RolandAddress { get }

}

//public protocol RolandPatchTrussBuilder : PatchTrussBuilder, RolandSysexTrussBuilder {
//  
////  static func sysexData(_ bodyData: PatchTruss.BodyData, deviceId: UInt8, address: RolandAddress) -> [[UInt8]]
//
//}
//
//public extension RolandPatchTrussBuilder {
//
//  static func o(
//    _ path: SynthPath,
//    _ b: Int? = nil,
//    l: String? = nil,
//                  p: Int? = nil,
//                  bit: Int? = nil,
//                  bits: ClosedRange<Int>? = nil,
//                  extra: [Int:Int] = [:],
//                  range: ClosedRange<Int>? = nil,
//                  max: Int? = nil,
//                  dispOff: Int = 0,
//                  opts: [Int:String]? = nil,
//                  optArray: [String]? = nil,
//                  isoF: Iso<Float,Float>? = nil,
//                  isoS: Iso<Float,String>? = nil
//  ) -> ParamOptions {
//    // default p to 1 since p is the byte count (instead of p defaulting to b value)
//    return ParamOptions(label: l, path: path, p: p ?? 1, b: b, bit: bit, bits: bits, extra: extra, range: range, max: max, dispOff: dispOff, opts: opts, optArray: optArray, isoF: isoF, isoS: isoS)
//  }
//  
//  // 2-byte param
//  static func o2(
//    _ path: SynthPath,
//    _ b: Int? = nil,
//    l: String? = nil,
//                  p: Int? = nil,
//                  bit: Int? = nil,
//                  bits: ClosedRange<Int>? = nil,
//                  extra: [Int:Int] = [:],
//                  range: ClosedRange<Int>? = nil,
//                  max: Int? = nil,
//                  dispOff: Int = 0,
//                  opts: [Int:String]? = nil,
//                  optArray: [String]? = nil,
//                  isoF: Iso<Float,Float>? = nil,
//                  isoS: Iso<Float,String>? = nil
//  ) -> ParamOptions {
//    o(path, b, l: l, p: 2, bit: bit, bits: bits, extra: extra, range: range, max: max, dispOff: dispOff, opts: opts, optArray: optArray, isoF: isoF, isoS: isoS)
//  }
//
//  // needs to use RolandAddress for byte math
//  static func inc(b: Int? = nil, p: Int? = nil, inc: Int = 1, block: @escaping (() -> [ParamOptions])) -> [ParamOptions] {
//    let blockPairs = block()
//    let rolandB = RolandAddress(b ?? 0)
//    return blockPairs.enumerated().map {
//      var newOpts = $0.element
//      if b != nil {
//        newOpts.b = (rolandB + RolandAddress($0.offset) * inc).value
//      }
//      if let p = p {
//        newOpts.p = p + $0.offset * inc
//      }
//      return newOpts
//    }
//  }
//  
//}
//
