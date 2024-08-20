

public func optimizedConcat<BodyData>(_ fns: [SysexTrussCore<BodyData>.ToMidiFn]) -> [SysexTrussCore<BodyData>.ToMidiFn] {
  guard fns.count > 1 else { return fns }
  var index = 0
  var optFns = [SysexTrussCore<BodyData>.ToMidiFn]()
  
  while index + 1 < fns.count {
    let a = fns[index]
    let b = fns[index + 1]
    if let c = a.optConcat(b) {
      optFns.append(c)
      index += 2
    }
    else {
      optFns.append(a)
      index += 1
    }
  }

  // if there was no improvement, we're done
  guard optFns.count < fns.count else { return optFns }
  // otherwise, see if we can reduce further.
  return optimizedConcat(optFns)
}

public func optimizedCompose<BodyData>(_ fns: [SysexTrussCore<BodyData>.ToMidiFn]) -> [SysexTrussCore<BodyData>.ToMidiFn] {
  guard fns.count > 1 else { return fns }
  var index = 0
  var optFns = [SysexTrussCore<BodyData>.ToMidiFn]()
  
  while index + 1 < fns.count {
    let a = fns[index]
    let b = fns[index + 1]
    if let c = a.optCompose(b) {
      optFns.append(c)
      index += 2
    }
    else {
      optFns.append(a)
      index += 1
    }
  }

  // if there was no improvement, we're done
  guard optFns.count < fns.count else { return optFns }
  // otherwise, see if we can reduce further.
  return optimizedCompose(optFns)
}

public struct SysexTrussCore<BodyData> {
  
  public enum ToMidiFn {
    case fn((_ b: BodyData, _ e: AnySynthEditor?) throws -> [UInt8])
    case b((_ b: BodyData) throws -> [UInt8])
    case e((_ e: AnySynthEditor?) throws -> [UInt8])
    case const([UInt8])
    case ident
    
    public func call(_ b: BodyData, _ e: AnySynthEditor?) throws -> [UInt8] {
      switch self {
      case .fn(let fn):
        return try fn(b, e)
      case .b(let fn):
        return try fn(b)
      case .e(let fn):
        return try fn(e)
      case .const(let bytes):
        return bytes
      case .ident:
        guard let b = b as? [UInt8] else {
          throw SysexTrussError.incorrectSysexType(msg: "ident should only be called on SinglePatchTruss")
        }
        return b
      }
    }
    
    // if possible, return an optimized fn for the concatenation of these 2 fns
    public func optConcat(_ other: ToMidiFn) -> ToMidiFn? {
      guard case .const(let myBytes) = self else { return nil }
      guard case .const(let otherBytes) = other else { return nil }
      return .const(myBytes + otherBytes)
    }
    
    // if possible, return an optimized composition of these 2 fns
    public func optCompose(_ other: ToMidiFn) -> ToMidiFn? {
      if case .ident = self {
        return other
      }
      else if case .ident = other {
        return self
      }
      return nil
    }
    
  }
//  public typealias ToMidiFn = (_ b: BodyData, _ e: AnySynthEditor?) throws -> [UInt8]
  
  public typealias ParseBodyDataFn = ([UInt8]) throws -> BodyData
  public typealias ValidSizeFn = (Int) -> Bool
  public typealias ValidDataFn = ([UInt8]) -> Bool
  public typealias ValidBundle = (
    validSize: ValidSizeFn,
    validData: ValidDataFn,
    completeFetch: ValidDataFn
  )

  public let displayId: String
  public let initFileName: String
  public let maxNameCount: Int
  public let fileDataCount: Int

  public let defaultName: String?

  public let createFileData: ToMidiFn
  public let parseBodyData: ParseBodyDataFn

  public let isValidSize: ValidSizeFn
  public let isValidFileData: ValidDataFn
  public let isCompleteFetch: ValidDataFn
    
  public init(_ displayId: String, initFile: String = "", maxNameCount: Int = 32, fileDataCount: Int, defaultName: String? = nil, createFileData: ToMidiFn, parseBodyData: @escaping ParseBodyDataFn, isValidSize: ValidSizeFn? = nil, isValidFileData: ValidDataFn? = nil, isCompleteFetch: ValidDataFn? = nil) {
    self.displayId = displayId
    self.initFileName = initFile
    self.maxNameCount = maxNameCount
    self.fileDataCount = fileDataCount
    self.defaultName = defaultName
    self.createFileData = createFileData
    self.parseBodyData = parseBodyData
    
    let isValidSize = isValidSize ?? { $0 == fileDataCount }
    self.isValidSize = isValidSize
    self.isValidFileData = isValidFileData ?? Self.validDataFn(isValidSize)
    self.isCompleteFetch = isCompleteFetch ?? Self.validDataFn(isValidSize)
  }

  public init(_ displayId: String, initFile: String = "", maxNameCount: Int = 32, fileDataCount: Int, defaultName: String? = nil, createFileData: ToMidiFn, parseBodyData: @escaping ParseBodyDataFn, validBundle bundle: ValidBundle? = nil) {
    
    self = Self.init(displayId, initFile: initFile, maxNameCount: maxNameCount, fileDataCount: fileDataCount, defaultName: defaultName, createFileData: createFileData, parseBodyData: parseBodyData, isValidSize: bundle?.validSize, isValidFileData: bundle?.validData, isCompleteFetch: bundle?.completeFetch)
  }

  public init(_ displayId: String, initFile: String = "", maxNameCount: Int = 32, fileDataCount: Int, defaultName: String? = nil, createFileData: ToMidiFn, parseBodyData: @escaping ParseBodyDataFn, isValidSizeDataAndFetch validSizeFn: @escaping ValidSizeFn) {
    let validDataFn = Self.validDataFn(validSizeFn)
    self = Self.init(displayId, initFile: initFile, maxNameCount: maxNameCount, fileDataCount: fileDataCount, defaultName: defaultName, createFileData: createFileData, parseBodyData: parseBodyData, isValidSize: validSizeFn, isValidFileData: validDataFn, isCompleteFetch: validDataFn)
  }
  
  public static func validDataFn(_ validSizeFn: @escaping ValidSizeFn) -> ValidDataFn {
    { validSizeFn($0.count) }
  }
  
  public static func validBundle(counts: [Int]) -> ValidBundle {
    validBundle(validSize: { counts.contains($0) })
  }
  
  public static func validBundle(validSize: @escaping ValidSizeFn) -> ValidBundle {
    let validData = validDataFn(validSize)
    return (
      validSize: validSize,
      validData: validData,
      completeFetch: validData
    )
  }
  
}
