
infix operator <<<: MultiplicationPrecedence
infix operator ---: MultiplicationPrecedence

@discardableResult
public func <<<<K,V>(_ lhs: Dictionary<K, V>, _ rhs: Dictionary<K, V>) -> Dictionary<K, V> {
  return lhs.merging(rhs) { $1 }
}

@discardableResult
public func <<<(_ lhs: [ParamOptions], _ rhs: [ParamOptions]) -> [ParamOptions] {
  return lhs + rhs
}

@discardableResult
public func <<<<T>(_ lhs: SynthPathTree<T>, _ rhs: SynthPathTree<T>) -> SynthPathTree<T> {
  return lhs.merging(rhs)
}

@discardableResult
public func <<<<T>(_ lhs: SynthPathTree<T>, _ rhs: [SynthPath:T]) -> SynthPathTree<T> {
  var d = lhs
  rhs.forEach {
    d[$0.key] = $0.value
  }
  return d
}

public func merged<K,V>(_ arr :[Dictionary<K,V>]) -> Dictionary<K,V> {
  return arr.reduce([:]) { $0 <<< $1 }
}

@discardableResult
public func ---<K,V>(_ lhs: Dictionary<K, V>, _ rhs: Array<K>) -> Dictionary<K, V> {
  var d = lhs
  rhs.forEach {
    d.removeValue(forKey: $0)
  }
  return d
}

@discardableResult
public func ---(_ lhs: SynthPathParam, _ rhs: [SynthPath]) -> SynthPathParam {
  var d = lhs
  rhs.forEach {
    d.removeValue(forKey: $0)
  }
  return d
}


@discardableResult
public func <<<(_ lhs: [Parm], _ rhs: [Parm]) -> [Parm] {
  return lhs + rhs
}

public struct Parm {
  
  public var label: String? = nil
  public var path: SynthPath = []
  public var p: Int? = nil
  public var b: Int? = nil
  public var bits: ClosedRange<Int>? = nil
  public var extra: [Int:Int] = [:]
  public var packIso: PackIso? = nil
  public var span: Span

  public init(label: String? = nil, path: SynthPath, p: Int? = nil, b: Int? = nil, bits: ClosedRange<Int>? = nil, extra: [Int : Int] = [:], packIso: PackIso? = nil, span: Span) {
    self.label = label
    self.path = path
    self.p = p
    self.b = b
    self.bits = bits
    self.extra = extra
    self.packIso = packIso
    self.span = span
  }
  
  public enum Span {
    case rng(_ range: ClosedRange<Int>? = nil, dispOff: Int = 0)
    case options(_ opts: [Int : String])
    case isoF(_ isoF: IsoFF, range: ClosedRange<Int>? = nil)
    case isoS(_ isoS: IsoFS, range: ClosedRange<Int>? = nil)
    
    public var range: ClosedRange<Int> {
      switch self {
      case .rng(let r, _), .isoF(_, let r), .isoS(_, let r):
        return r ?? 0...127
      case .options(let opts):
        return (opts.keys.min() ?? 0)...(opts.keys.max() ?? 0)
      }
    }
    
    public var dispOff: Int {
      switch self {
      case .rng(_, let dispOff):
        return dispOff
      default:
        return 0
      }
    }
    
  }
  
  public func param() -> Param {
    let b = b ?? 0
    let p = p ?? 0 // NOTE: THIS USED TO DEFAULT TO b, not 0. This is going to cause problems with some synths, no doubt.
    switch span {
    case .rng(let range, let dispOff):
      return RangeParam(parm: p, byte: b, bits: bits, extra: extra, range: range ?? 0...127, displayOffset: dispOff, packIso: packIso)
    case .options(let options):
      return OptionsParam(parm: p, byte: b, bits: bits, extra: extra, options: options, packIso: packIso)
    case .isoF(let isoF, let range):
      return MisoParam.make(parm: p, byte: b, bits: bits, extra: extra, range: range ?? 0...127, iso: isoF, packIso: packIso)
    case .isoS(let isoS, let range):
      return MisoParam.make(parm: p, byte: b, bits: bits, extra: extra, range: range ?? 0...127, iso: isoS, packIso: packIso)
    }
  }
}

public extension Parm.Span {
  static func max(_ max: Int, dispOff: Int = 0) -> Self { .rng(0...max, dispOff: dispOff) }
  static func opts(_ opts: [String]) -> Self { .options(OptionsParam.makeOptions(opts)) }
  static func iso(_ iso: IsoFF, _ range: ClosedRange<Int>? = nil) -> Self {
    .isoF(iso, range: range)
  }
  static func iso(_ iso: IsoFS, _ range: ClosedRange<Int>? = nil) -> Self {
    .isoS(iso, range: range)
  }
}

public extension Parm {
  
  func prefixed(_ pre: SynthPath) -> Self {
    var p = self
    p.path = pre + self.path
    return p
  }

  func suffixed(_ suf: SynthPath) -> Self {
    var p = self
    p.path = self.path + suf
    return p
  }

  static func p(l: String? = nil, _ path: SynthPath, _ b: Int? = nil, p: Int? = nil, bit: Int, extra: [Int : Int] = [:], packIso: PackIso? = nil, _ span: Span = .rng()) -> Self {
    .init(label: l, path: path, p: p, b: b, bits: bit...bit, extra: extra, packIso: packIso, span: span)
  }

  static func p(l: String? = nil, _ path: SynthPath, _ b: Int? = nil, p: Int? = nil, bits: ClosedRange<Int>? = nil, extra: [Int : Int] = [:], packIso: PackIso? = nil, _ span: Span = .rng()) -> Self {
    .init(label: l, path: path, p: p, b: b, bits: bits, extra: extra, packIso: packIso, span: span)
  }

  static func p(l: String? = nil, _ path: SynthPath, p: Int? = nil, bits: ClosedRange<Int>? = nil, extra: [Int : Int] = [:], packIso: PackIso? = nil, _ span: Span = .rng()) -> Self {
    .init(label: l, path: path, p: p, b: nil, bits: bits, extra: extra, packIso: packIso, span: span)
  }

}

public extension Array where Element == Parm {
  
  func params() -> SynthPathParam {
    dict { [$0.path : $0] }
  }
  
  var paths: [SynthPath] {
    map { $0.path }
  }
  
  func prefix(_ prefix: SynthPath) -> Self {
    map { $0.prefixed(prefix) }
  }

  static func prefix(_ pfx: SynthPath, count: Int, bx: Int, px: Int? = nil, block: @escaping ((Int) throws -> Self)) throws -> Self {
    return try (0..<count).flatMap { i in
      let p = px == nil ? nil : px! * i
      let blockArr = try block(i)
      return blockArr.offset(b: bx * i, p: p).prefix(pfx + [.i(i)])
    }
  }

  static func prefixes(_ pfxs: [SynthPath], bx: Int, px: Int? = nil, block: @escaping ((SynthPath) -> Self)) -> Self {
    return pfxs.enumerated().flatMap { (i, pfx) in
      let p = px == nil ? nil : px! * i
      let blockDict = block(pfx)
      return blockDict.offset(b: bx * i, p: p).prefix(pfx)
    }
  }
  
  static func suffix(_ suffix: SynthPath, block: @escaping (() -> Self)) -> Self {
    block().map { $0.suffixed(suffix) }
  }

  static func suffix(_ sfx: SynthPath, count: Int, bx: Int, px: Int? = nil, block: @escaping ((Int) -> Self)) -> Self {
    return (0..<count).flatMap { i in
      let p = px == nil ? nil : px! * i
      let blockArr = block(i)
      return suffix([.i(i)] + sfx) {
        blockArr.offset(b: bx * i, p: p)
      }
    }
  } 

  func offset(b: Int, p: Int? = nil) -> Self {
    map {
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
  
  func inc(b: Int? = nil, p: Int? = nil, inc: Int = 1) -> Self {
    enumerated().map {
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
  
  /// Copy all b values to p. If b is nil, skip.
  func b2p() -> Self {
    map {
      var newOpts = $0
      if let bb = newOpts.b {
        newOpts.p = bb
      }
      return newOpts
    }
  }
  
}
