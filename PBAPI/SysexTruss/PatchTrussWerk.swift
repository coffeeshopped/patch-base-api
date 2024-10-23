
public struct PatchTrussWerk {
  
}

public extension PatchTrussWerk {
  
  static func o(
    _ path: SynthPath,
    _ b: Int? = nil,
    l: String? = nil,
    p: Int? = nil,
    bit: Int? = nil,
    bits: ClosedRange<Int>? = nil,
    extra: [Int:Int] = [:],
    range: ClosedRange<Int>? = nil,
    max: Int? = nil,
    dispOff: Int = 0,
    opts: [Int:String]? = nil,
    optArray: [String]? = nil,
    isoF: IsoFF? = nil,
    isoS: IsoFS? = nil
  ) -> ParamOptions {
    return ParamOptions(label: l, path: path, p: p ?? b, b: b, bit: bit, bits: bits, extra: extra, range: range, max: max, dispOff: dispOff, opts: opts, optArray: optArray, isoF: isoF, isoS: isoS)
  }

  static func opts(_ arr: [String]) -> [Int:String] { OptionsParam.makeOptions(arr) }
  
  static func prefix(_ prefix: SynthPath, block: @escaping (() -> [ParamOptions])) -> [ParamOptions] {
    return block().map {
      var po = $0
      po.path = prefix + po.path
      return po
    }
  }

//  static func prefix(_ prefix: SynthPath, block: @escaping (() -> [SynthPath:ParamOptions])) -> [SynthPath:ParamOptions] {
//    return block().prefixed(prefix)
//  }

  static func prefix(_ pfx: SynthPath, count: Int, bx: Int, px: Int? = nil, block: @escaping ((Int) -> [ParamOptions])) -> [ParamOptions] {
    return (0..<count).map { i in
      let p = px == nil ? nil : px! * i
      let blockArr = block(i)
      return prefix(pfx + [.i(i)]) {
        offset(b: bx * i, p: p) { blockArr }
      }
    }.reduce([]) { $0 + $1 }
  }

  static func prefixes(_ pfxs: [SynthPath], bx: Int, px: Int? = nil, block: @escaping ((SynthPath) -> [ParamOptions])) -> [ParamOptions] {
    return pfxs.enumerated().map { (i, pfx) in
      let p = px == nil ? nil : px! * i
      let blockDict = block(pfx)
      return prefix(pfx) {
        offset(b: bx * i, p: p) {
          blockDict
        }
      }
    }.reduce([]) { $0 + $1 }
  }
  
  static func suffix(_ suffix: SynthPath, block: @escaping (() -> [ParamOptions])) -> [ParamOptions] {
    block().map {
      var po = $0
      po.path = po.path + suffix
      return po
    }
  }

  static func suffix(_ sfx: SynthPath, count: Int, bx: Int, px: Int? = nil, block: @escaping ((Int) -> [ParamOptions])) -> [ParamOptions] {
    return (0..<count).map { i in
      let p = px == nil ? nil : px! * i
      let blockArr = block(i)
      return suffix([.i(i)] + sfx) {
        offset(b: bx * i, p: p) { blockArr }
      }
    }.reduce([]) { $0 + $1 }
  }


  static func offset(b: Int, p: Int? = nil, block: @escaping (() -> [ParamOptions])) -> [ParamOptions] {
    return block().map {
      var newOpts = $0
      if let bb = newOpts.b {
        newOpts.b = bb + b
      }
      if let pp = newOpts.p, let off = p {
        newOpts.p = pp + off
      }
      return newOpts
    }
  }
  

  static func inc(b: Int? = nil, p: Int? = nil, inc: Int = 1, block: @escaping (() -> [ParamOptions])) -> [ParamOptions] {
    let blockPairs = block()
    return blockPairs.enumerated().map {
      var newOpts = $0.element
      if let b = b {
        newOpts.b = b + $0.offset * inc
      }
      if let p = p {
        newOpts.p = p + $0.offset * inc
      }
      return newOpts
    }
  }

  /// Transform array of ParamOptions to dictionary. Later entries in the array with duplicate paths will overwrite earlier entries in the resulting dictionary.
//  static func paramsFromOpts(_ ins: [ParamOptions]) -> SynthPathParam {
//    var dict = SynthPathParam()
//    ins.forEach { po in
//      dict[po.path] = po.param()
//    }
//    return dict
//  }
}

