
public protocol Param {
  var byte: Int { get }
  var bits: ClosedRange<Int>? { get }
  
  var parm: Int { get }
  var extra: [Int:Int] { get }

  func randomize() -> Int
  
  var packIso: PackIso? { get }
}

public protocol ParamWithRange: Param {
  var range: ClosedRange<Int> { get }
  var displayOffset: Int { get }
  var formatter: ParamValueFormatter? { get }
  var parser: ParamValueParser? { get }
}

public protocol ParamWithOptions : Param {
  var options: [Int:String] { get }
}

public typealias ParamValueFormatter = ((Int) -> String)
public typealias ParamValueParser = ((String) -> Int)
public typealias ParamValueMapper = (format: ParamValueFormatter, parse: ParamValueParser)

public extension IsoFS {

  func pvm() -> ParamValueMapper {
    (
      format: { forward(Float($0)) },
      parse: { Int(round(backward($0))) }
    )
  }

}

public struct MisoParam {
  
  public static func make(parm: Int = 0, byte: Int = 0, bits: ClosedRange<Int>? = nil, extra: [Int:Int] = [:], options: [String], startIndex: Int = 0) -> RangeParam {
    let iso = IsoFS.options(options, startIndex: startIndex)
    let mapper = iso.pvm()
    let r = RangeParam(parm: parm, byte: byte, bits: bits, extra: extra, range: startIndex...(startIndex + options.count - 1), formatter: mapper.format, parser: mapper.parse)
    return r
  }
  
  public static func make(parm: Int = 0, byte: Int = 0, bits: ClosedRange<Int>? = nil, extra: [Int:Int] = [:], range: ClosedRange<Int> = 0...127, displayOffset: Int = 0, iso: IsoFS, packIso: PackIso? = nil) -> RangeParam {
    let r = RangeParam(parm: parm, byte: byte, bits: bits, extra: extra, range: range, displayOffset: displayOffset, mapper: iso.pvm(), packIso: packIso)
    return r
  }

  public static func make(parm: Int = 0, byte: Int = 0, bits: ClosedRange<Int>? = nil, extra: [Int:Int] = [:], maxVal: Int, displayOffset: Int = 0, iso: IsoFS, packIso: PackIso? = nil) -> RangeParam {
    let r = RangeParam(parm: parm, byte: byte, bits: bits, extra: extra, maxVal: maxVal, displayOffset: displayOffset, mapper: iso.pvm(), packIso: packIso)
    return r
  }

  public static func make(parm: Int = 0, byte: Int = 0, bits: ClosedRange<Int>? = nil, extra: [Int:Int] = [:], range: ClosedRange<Int> = 0...127, displayOffset: Int = 0, iso: IsoFF, packIso: PackIso? = nil) -> RangeParam {
    let r = RangeParam(parm: parm, byte: byte, bits: bits, extra: extra, range: range, displayOffset: displayOffset, mapper: (iso >>> .str()).pvm(), packIso: packIso)
    return r
  }

  public static func make(parm: Int = 0, byte: Int = 0, bits: ClosedRange<Int>? = nil, extra: [Int:Int] = [:], maxVal: Int, displayOffset: Int = 0, iso: IsoFF, packIso: PackIso? = nil) -> RangeParam {
    let r = RangeParam(parm: parm, byte: byte, bits: bits, extra: extra, maxVal: maxVal, displayOffset: displayOffset, mapper: (iso >>> .str()).pvm(), packIso: packIso)
    return r
  }

}


public struct RangeParam : ParamWithRange {
  public let range: ClosedRange<Int>
  public let displayOffset: Int
  public let byte: Int
  public let bits: ClosedRange<Int>?
  public let parm: Int
  public let extra: [Int:Int]
  public let formatter: ParamValueFormatter?
  public let parser: ParamValueParser?
  public let packIso: PackIso?

  public init(parm p: Int = 0, byte by: Int = 0, bits bts: ClosedRange<Int>? = nil, extra x: [Int:Int] = [:], range r: ClosedRange<Int> = 0...127, displayOffset off: Int = 0, formatter: ParamValueFormatter? = nil, parser: ParamValueParser? = nil, packIso: PackIso? = nil) {
    parm = p
    byte = by
    bits = bts
    extra = x
    range = r
    displayOffset = off
    self.formatter = formatter
    self.parser = parser
    self.packIso = packIso
  }

  public init(parm p: Int = 0, byte by: Int = 0, bits bts: ClosedRange<Int>? = nil, extra x: [Int:Int] = [:], maxVal: Int, displayOffset off: Int = 0, formatter: ParamValueFormatter? = nil, parser: ParamValueParser? = nil, packIso: PackIso? = nil) {
    self.init(parm: p, byte: by, bits: bts, extra: x, range: 0...maxVal, displayOffset: off, formatter: formatter, parser: parser, packIso: packIso)
  }
  
  public init(parm p: Int = 0, byte by: Int = 0, bit bt: Int, extra x: [Int:Int] = [:], formatter: ParamValueFormatter? = nil, parser: ParamValueParser? = nil, packIso: PackIso? = nil) {
    parm = p
    byte = by
    bits = bt...bt
    extra = x
    range = 0...1
    displayOffset = 0
    self.formatter = formatter
    self.parser = parser
    self.packIso = packIso
  }

  // MAPPER
  
  public init(parm p: Int = 0, byte by: Int = 0, bits bts: ClosedRange<Int>? = nil, extra x: [Int:Int] = [:], range r: ClosedRange<Int> = 0...127, displayOffset off: Int = 0, mapper: ParamValueMapper, packIso: PackIso? = nil) {
    self.init(parm: p, byte: by, bits: bts, extra: x, range: r, displayOffset: off, formatter: mapper.format, parser: mapper.parse, packIso: packIso)
  }

  public init(parm p: Int = 0, byte by: Int = 0, bits bts: ClosedRange<Int>? = nil, extra x: [Int:Int] = [:], maxVal: Int, displayOffset off: Int = 0, formatter: ParamValueFormatter? = nil, mapper: ParamValueMapper, packIso: PackIso? = nil) {
    self.init(parm: p, byte: by, bits: bts, extra: x, range: 0...maxVal, displayOffset: off, formatter: mapper.format, parser: mapper.parse, packIso: packIso)
  }
  
  public init(parm p: Int = 0, byte by: Int = 0, bit bt: Int, extra x: [Int:Int] = [:], mapper: ParamValueMapper, packIso: PackIso? = nil) {
    self.init(parm: p, byte: by, bit: bt, extra: x, formatter: mapper.format, parser: mapper.parse, packIso: packIso)
  }
  
  public func randomize() -> Int {
    return range.lowerBound + Int(arc4random_uniform(UInt32(1 + range.upperBound - range.lowerBound)))
  }
}

public struct OptionsParam : ParamWithOptions, ParamWithRange {
  public let options: [Int:String]
  public let byte: Int
  public let bits: ClosedRange<Int>?
  public let parm: Int
  public let extra: [Int:Int]
  public var range: ClosedRange<Int> {
    return (options.keys.min() ?? 0)...(options.keys.max() ?? 0)
  }
  public let displayOffset = 0
  public let formatter: ParamValueFormatter? = nil
  public let parser: ParamValueParser? = nil
  public let packIso: PackIso?


  public init(parm p: Int = 0, byte by: Int = 0, bits bts: ClosedRange<Int>? = nil, extra x: [Int:Int] = [:], options opts: [Int:String], packIso: PackIso? = nil) {
    parm = p
    options = opts
    byte = by
    bits = bts
    extra = x
    self.packIso = packIso
  }
  
  public init(parm p: Int = 0, byte by: Int = 0, bit bt: Int, extra x: [Int:Int] = [:], options opts: [Int:String], packIso: PackIso? = nil) {
    parm = p
    options = opts
    byte = by
    bits = bt...bt
    extra = x
    self.packIso = packIso
  }
  
  public func randomize() -> Int {
    return Array(options.keys)[Int(arc4random_uniform(UInt32(options.count)))]
  }
  
  public static func makeOptions(_ values: [String]) -> [Int:String] {
    return values.enumerated().reduce([Int:String](), { (dict, e) -> [Int:String] in
      var dict = dict
      dict[e.0] = e.1
      return dict
    })
  }

  public static func makeNumberedOptions(_ values: [String], offset: Int = 0) -> [Int:String] {
    return values.enumerated().reduce([Int:String](), { (dict, e) -> [Int:String] in
      var dict = dict
      dict[e.0] = "\(e.0 + offset): \(e.1)"
      return dict
    })
  }

}

extension Dictionary : ExpressibleByArrayLiteral where Key == Int, Value == String {
  public typealias ArrayLiteralElement = String
  
  public init(arrayLiteral elements: String...) {
    self.init()
    elements.enumerated().forEach { self[$0.offset] = $0.element }
  }
}

public extension Dictionary where Key == Int, Value == String {
  func numPrefix(offset: Int = 1) -> Self {
    dict {
      [$0.key : "\($0.key + offset): \($0.value)"]
    }
  }
}
