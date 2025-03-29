
public struct SinglePatchTruss : PatchTruss {
  
  public typealias BodyData = [UInt8]
  public func sysexBodyData(_ data: BodyData) -> SysexBodyData { .single(data) }

  public typealias PackFn = ((inout BodyData, Parm, Int) throws -> Void)
  public typealias UnpackFn = ((BodyData, Parm) throws -> Int?)
  public typealias RandomizeFn = () -> SynthPathInts

  public let core: Core
  
  /// The expected length of the BodyData array
  public let bodyDataCount: Int
  public let namePackIso: NamePackIso?
  public let params: SynthPathParam

  public let unpack: UnpackFn //= defaultUnpack
  public let pack: PackFn //= defaultPack
  private let _randomize: RandomizeFn

  public indirect enum Error : LocalizedError {
    case msg(String)
    case wrap(String, Swift.Error)
    
    public var errorDescription: String? {
      switch self {
      case .msg(let s):
        return s
      case .wrap(let s, let e):
        return "\(s): \(e.localizedDescription)"
      }
    }
  }
  
  public init(_ core: Core, bodyDataCount: Int, namePackIso: NamePackIso? = nil, params: SynthPathParam, pack: PackFn? = nil, unpack: UnpackFn? = nil, randomize: RandomizeFn? = nil) {

    self.bodyDataCount = bodyDataCount
    self.namePackIso = namePackIso
    self.params = params
    self.pack = pack ?? Self.defaultPack
    self.unpack = unpack ?? Self.defaultUnpack
    self._randomize = {
      .init(params.dict { [$0.key : $0.value.span.randomize()] }) <<< (randomize?() ?? [:])
    }
    self.core = core
  }

  public init(_ displayId: String, _ bodyDataCount: Int, namePackIso: NamePackIso? = nil, params: SynthPathParam, initFile: String = "", defaultName: String? = nil, createFileData: Core.ToMidiFn? = nil, parseBodyData: Core.ParseBodyDataFn? = nil, validBundle: ValidBundle? = nil, pack: PackFn? = nil, unpack: UnpackFn? = nil, randomize: RandomizeFn? = nil) throws {

    let fileDataCount: Int
    if let createFileData = createFileData {
      fileDataCount = try Self.fileDataCount(createFileData: createFileData, bodyDataCount: bodyDataCount)
    }
    else {
      fileDataCount = 0
    }
    
    let createFileData = createFileData ?? .fn({ _, _ in
      throw SysexTrussError.blockNotSet(msg: "createFileData called but never set.")
    })
    let parseBodyData = parseBodyData ?? { _ in
      throw SysexTrussError.blockNotSet(msg: "\(displayId): parseBodyData called but never set.")
    }

    let maxNameCount = namePackIso?.byteRange.count ?? 32
    let core = SysexTrussCore<BodyData>(displayId, initFile: initFile, maxNameCount: maxNameCount, fileDataCount: fileDataCount, defaultName: defaultName, createFileData: createFileData, parseBodyData: parseBodyData, validBundle: validBundle)
    
    self = Self.init(core, bodyDataCount: bodyDataCount, namePackIso: namePackIso, params: params, pack: pack, unpack: unpack, randomize: randomize)
  }
  
  public init(_ displayId: String, _ bodyDataCount: Int, namePackIso: NamePackIso? = nil, params: SynthPathParam, initFile: String = "", defaultName: String? = nil, createFileData: Core.ToMidiFn? = nil, parseOffset: Int, validBundle: ValidBundle? = nil, pack: PackFn? = nil, unpack: UnpackFn? = nil, randomize: RandomizeFn? = nil) throws {
    
    let parseBodyData = Self.parseBodyDataFn(parseOffset: parseOffset, bodyDataCount: bodyDataCount)
    self = try Self.init(displayId, bodyDataCount, namePackIso: namePackIso, params: params, initFile: initFile, defaultName: defaultName, createFileData: createFileData, parseBodyData: parseBodyData, validBundle: validBundle, pack: pack, unpack: unpack, randomize: randomize)
  }
  
  
  public init(_ displayId: String, _ bodyDataCount: Int, namePackIso: NamePackIso? = nil, params: SynthPathParam, initFile: String = "", defaultName: String? = nil, createFileData: Core.ToMidiFn, parseBodyData: @escaping Core.ParseBodyDataFn, validSizes: [Int], includeFileDataCount: Bool, pack: PackFn? = nil, unpack: UnpackFn? = nil, randomize: RandomizeFn? = nil) throws {

    let fileDataCount = try Self.fileDataCount(createFileData: createFileData, bodyDataCount: bodyDataCount)
    let finalValidSizes = (includeFileDataCount ? [fileDataCount] : []) + validSizes
    
    self = try Self.init(displayId, bodyDataCount, namePackIso: namePackIso, params: params, initFile: initFile, defaultName: defaultName, createFileData: createFileData, parseBodyData: parseBodyData, validBundle: .init(sizes: finalValidSizes), pack: pack, unpack: unpack, randomize: randomize)
  }
  
  private static func fileDataCount(createFileData: Core.ToMidiFn, bodyDataCount: Int) throws -> Int {
    try createFileData.call([UInt8](repeating: 0, count: bodyDataCount), nil).reduce(0, { $0 + $1.count })
  }
      
//  public mutating func set(paramsFromOpts opts: [ParamOptions]) {
//    self.params = paramsFromOpts(opts)
//  }
  
//  func randomize(patch: SingleSysexPatch<Self>)
  
  public func parm(_ path: SynthPath) -> Parm? { params[path] }
  public func paramKeys() -> [SynthPath] { Array(params.keys) }
  
  public func subpaths(_ path: SynthPath) -> [SynthPath]? { [path] }

  public func createEmptyBodyData() throws -> BodyData {
    [UInt8](repeating: 0, count: bodyDataCount)
  }
  
  public func getValue(_ bodyData: BodyData, path: SynthPath) throws -> Int? {
    guard let param = params[path] else { return nil }
    if let unpack = param.packIso?.unpack {
      return unpack(bodyData)
    }
    else {
      do {
        return try unpack(bodyData, param)
      }
      catch {
        throw Error.wrap("Error in Truss (\(displayId) getValue (path: \(path.str()))", error)
      }
    }
  }
  
  public func setValue(_ bodyData: inout BodyData, path: SynthPath, _ value: Int) {
    guard let param = params[path] else { return }
    // if the param has a packIso, use that, otherwise, use truss pack
    if let pack = param.packIso?.pack {
      pack(&bodyData, value)
    }
    else {
      try! pack(&bodyData, param, value)
    }
  }
    
  public func allValues(_ bodyData: BodyData) throws -> SynthPathInts {
    var v = SynthPathInts()
    try params.keys.forEach {
      guard let value = try getValue(bodyData, path: $0) else { return }
      v[$0] = value
    }
    return v
  }
  
  public static func defaultPack(bodyData: inout BodyData, param: Parm, value: Int) {
    bodyData[param.b!] = defaultPackedByte(value: value, forParam: param, byte: bodyData[param.b!])
  }

  public static func defaultUnpack(bodyData: BodyData, param: Parm) throws -> Int? {
    guard let b = param.b else {
      throw Error.msg("default Unpack method used for Param without a 'b' value (required)")
    }
    return defaultUnpackedByte(byte: b, bits: param.bits, bytes: bodyData)
  }

  public static func defaultUnpackedByte(byte: Int, bits: ClosedRange<Int>?, bytes: [UInt8]) -> Int? {
    // range check
    guard byte < bytes.count else { return nil }
    // if no bits set, just return byte
    guard let bits = bits else { return Int(bytes[byte]) }
    
    let ander = (1 << (1 + bits.upperBound - bits.lowerBound)) - 1
    return (Int(bytes[byte]) >> bits.lowerBound) & ander
  }

  public static func defaultPackedByte(value: Int, forParam param: Parm, byte: UInt8) -> UInt8 {
    guard let bits = param.bits else {
      // use bitpattern init to handle negative values
      return value < 0 ? UInt8(bitPattern: Int8(value)) : UInt8(value)
    }
    
    let bitlen = 1 + (bits.upperBound - bits.lowerBound)
    let bitmask = (1 << bitlen) - 1 // all 1's
    var b = Int(byte)
    // clear the bits
    b &= ~(bitmask << bits.lowerBound)
    // set the bits
    b |= ((value & bitmask) << bits.lowerBound)
    return UInt8(b)
  }
    
  public func getName(_ bodyData: BodyData) -> String? {
    try! namePackIso?.unpack(bodyData)
  }
  
  public func setName(_ bodyData: inout BodyData, _ value: String) {
    try! namePackIso?.pack(&bodyData, value)
  }
    
  public func getName(_ bodyData: BodyData, forPath path: SynthPath) -> String? {
    path.count == 0 ? getName(bodyData) : nil
  }
  
  public func setName(_ bodyData: inout BodyData, forPath path: SynthPath, _ name: String) {
    guard path.count > 0 else { return setName(&bodyData, name) }
  }
  
  public func allNames(_ bodyData: BodyData) -> [SynthPath:String] {
    guard let name = getName(bodyData) else { return [:] }
    return [[] : name]
  }
  
  public func randomize() -> SynthPathInts { _randomize() }

}

public extension SinglePatchTruss {
  
  /// Take some bodyDataA based on trussA, and parse out the name/params then merge them into bodyDataB based on trussB
  static func transform(_ bodyDataA: BodyData, withTruss trussA: Self, into bodyDataB: inout BodyData, using trussB: Self) throws {
    if let name = trussA.getName(bodyDataA) {
      trussB.setName(&bodyDataB, name)
    }
    
    try trussA.params.keys.forEach {
      guard let v = try trussA.getValue(bodyDataA, path: $0) else { return }
      trussB.setValue(&bodyDataB, path: $0, v)
    }
  }

  func transform(_ bodyDataA: BodyData, into bodyDataB: inout BodyData, using trussB: Self) throws {
    try Self.transform(bodyDataA, withTruss: self, into: &bodyDataB, using: trussB)
  }

  /// Take bodyData based on some other truss and return bodyData with this Truss' length (bodyDataCount) and data transformed to it
  func parse(otherData: BodyData, otherTruss: Self) throws -> BodyData {
    var bodyData = [UInt8](repeating: 0, count: bodyDataCount)
    try otherTruss.transform(otherData, into: &bodyData, using: self)
    return bodyData
  }

}

public extension SinglePatchTruss {

  /// Set parseBodyData as a simple array copy from the given offset and bodyDataCount.
  static func parseBodyDataFn(parseOffset: Int, bodyDataCount: Int) -> Core.ParseBodyDataFn {
    /// bodyDataCount will be set bc it's set during constructor
    return {
      let upperBound = parseOffset + bodyDataCount
      let range = parseOffset..<upperBound
      guard $0.count < upperBound else { return [UInt8]($0[range]) }
      
      var d = $0
      let pad = [UInt8](repeating: 0, count: upperBound - $0.count)
      d.append(contentsOf: pad)
      return [UInt8](d[range])
    }
  }

}
