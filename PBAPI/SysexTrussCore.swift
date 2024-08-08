
public struct SysexTrussCore<BodyData> {
  public typealias CreateFileDataFn = (_ b: BodyData, _ e: [Any]) throws -> [UInt8]
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

  public let createFileData: CreateFileDataFn
  public let parseBodyData: ParseBodyDataFn

  public let isValidSize: ValidSizeFn
  public let isValidFileData: ValidDataFn
  public let isCompleteFetch: ValidDataFn
    
  public init(_ displayId: String, initFile: String = "", maxNameCount: Int = 32, fileDataCount: Int, defaultName: String? = nil, createFileData: @escaping CreateFileDataFn, parseBodyData: @escaping ParseBodyDataFn, isValidSize: ValidSizeFn? = nil, isValidFileData: ValidDataFn? = nil, isCompleteFetch: ValidDataFn? = nil) {
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

  public init(_ displayId: String, initFile: String = "", maxNameCount: Int = 32, fileDataCount: Int, defaultName: String? = nil, createFileData: @escaping CreateFileDataFn, parseBodyData: @escaping ParseBodyDataFn, validBundle bundle: ValidBundle? = nil) {
    
    self = Self.init(displayId, initFile: initFile, maxNameCount: maxNameCount, fileDataCount: fileDataCount, defaultName: defaultName, createFileData: createFileData, parseBodyData: parseBodyData, isValidSize: bundle?.validSize, isValidFileData: bundle?.validData, isCompleteFetch: bundle?.completeFetch)
  }

  public init(_ displayId: String, initFile: String = "", maxNameCount: Int = 32, fileDataCount: Int, defaultName: String? = nil, createFileData: @escaping CreateFileDataFn, parseBodyData: @escaping ParseBodyDataFn, isValidSizeDataAndFetch validSizeFn: @escaping ValidSizeFn) {
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
