
public struct ParamOptions {
  public init(label: String? = nil, path: SynthPath = [], p: Int? = nil, b: Int? = nil, bit: Int? = nil, bits: ClosedRange<Int>? = nil, extra: [Int : Int] = [:], range: ClosedRange<Int>? = nil, max: Int? = nil, dispOff: Int = 0, opts: [Int : String]? = nil, optArray: [String]? = nil, isoF: Iso<Float, Float>? = nil, isoS: Iso<Float, String>? = nil) {
    self.label = label
    self.path = path
    self.p = p
    self.b = b
    self.bit = bit
    self.bits = bits
    self.extra = extra
    self.range = range
    self.max = max
    self.dispOff = dispOff
    self.opts = opts
    self.optArray = optArray
    self.isoF = isoF
    self.isoS = isoS
  }
    
  public var label: String? = nil
  public var path: SynthPath
  public var p: Int? = nil
  public var b: Int? = nil
  public var bit: Int? = nil
  public var bits: ClosedRange<Int>? = nil
  public var extra: [Int:Int] = [:]
  public var range: ClosedRange<Int>? = nil
  public var max: Int? = nil
  public var dispOff: Int = 0
  public var opts: [Int:String]? = nil
  public var optArray: [String]? = nil
  public var isoF: Iso<Float,Float>? = nil
  public var isoS: Iso<Float,String>? = nil

  public func param() -> Param {
    let bits = self.bits == nil ? (self.bit == nil ? nil : (self.bit!...self.bit!)) : self.bits!
    let range = self.range == nil ? (self.max == nil ? 0...127 : (0...self.max!)) : self.range!
    let b = self.b ?? 0
    let p = self.p ?? b

    if let opts = self.opts {
      return OptionsParam(parm: p, byte: b, bits: bits, extra: self.extra, options: opts)
    }
    else if let optArray = self.optArray {
      let options = OptionsParam.makeOptions(optArray)
      return OptionsParam(parm: p, byte: b, bits: bits, extra: self.extra, options: options)
    }
    else if let iso = self.isoF {
      return MisoParam.make(parm: p, byte: b, bits: bits, extra: self.extra, range: range, displayOffset: self.dispOff, iso: iso)
    }
    else if let iso = self.isoS {
      return MisoParam.make(parm: p, byte: b, bits: bits, extra: self.extra, range: range, displayOffset: self.dispOff, iso: iso)
    }
    else {
      return RangeParam(parm: p, byte: b, bits: bits, extra: self.extra, range: range, displayOffset: self.dispOff)
    }
  }
}
