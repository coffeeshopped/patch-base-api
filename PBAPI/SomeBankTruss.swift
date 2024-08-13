
public struct SomeBankTruss<PT:PatchTruss> : BankTruss {
  
  public typealias BodyData = [PT.BodyData]
  public func sysexBodyData(_ data: BodyData) -> SysexBodyData {
    .bank(data.map { patchTruss.sysexBodyData($0)})
  }

  public let core: Core
    
  public let patchTruss: PT
  public let patchCount: Int
  
  public var anyPatchTruss: any PatchTruss { patchTruss }

  public init(patchTruss: PT, patchCount: Int, initFile: String = "", fileDataCount: Int? = nil, defaultName: String? = nil, createFileData: @escaping Core.ToMidiFn, parseBodyData: @escaping Core.ParseBodyDataFn, isValidSize: Core.ValidSizeFn? = nil, isValidFileData: Core.ValidDataFn? = nil, isCompleteFetch: Core.ValidDataFn? = nil) {
    self.patchTruss = patchTruss
    self.patchCount = patchCount

    let fileDataCount = fileDataCount ?? Self.fileDataCount(patchTruss: patchTruss, patchCount: patchCount)
    self.core = Core("\(patchTruss.displayId).bank", initFile: initFile, fileDataCount: fileDataCount, defaultName: defaultName, createFileData: createFileData, parseBodyData: parseBodyData, isValidSize: isValidSize, isValidFileData: isValidFileData, isCompleteFetch: isCompleteFetch)
  }

  public init(patchTruss: PT, patchCount: Int, initFile: String = "", fileDataCount: Int? = nil, defaultName: String? = nil, createFileData: @escaping Core.ToMidiFn, parseBodyData: @escaping Core.ParseBodyDataFn, validBundle bundle: Core.ValidBundle? = nil) {
    
    self = Self.init(patchTruss: patchTruss, patchCount: patchCount, initFile: initFile, fileDataCount: fileDataCount, defaultName: defaultName, createFileData: createFileData, parseBodyData: parseBodyData, isValidSize: bundle?.validSize, isValidFileData: bundle?.validData, isCompleteFetch: bundle?.completeFetch)
  }
  
  public init(patchTruss: PT, patchCount: Int, initFile: String = "", fileDataCount: Int? = nil, defaultName: String? = nil, createFileData: @escaping Core.ToMidiFn, parseBodyData: @escaping Core.ParseBodyDataFn, validSizes: [Int], includeFileDataCount: Bool) {
    
    let fileDataCount = Self.fileDataCount(patchTruss: patchTruss, patchCount: patchCount)
    let finalValidSizes = (includeFileDataCount ? [fileDataCount] : []) + validSizes
    let validBundle = Core.validBundle(counts: finalValidSizes)
    self = Self.init(patchTruss: patchTruss, patchCount: patchCount, initFile: initFile, fileDataCount: fileDataCount, defaultName: defaultName, createFileData: createFileData, parseBodyData: parseBodyData, validBundle: validBundle)
  }
  
  public static func fileDataCount(patchTruss: PT, patchCount: Int) -> Int {
    return patchCount * patchTruss.fileDataCount
  }
  
  /// Generate a ValidBundle using the default fileDataCount method plus any other valid sizes.
  public static func fileDataCountBundle(patchTruss: PT, patchCount: Int, validSizes: [Int], includeFileDataCount: Bool) -> Core.ValidBundle {
    let finalValidSizes = (includeFileDataCount ? [fileDataCount(patchTruss: patchTruss, patchCount: patchCount)] : []) + validSizes
    return Core.validBundle(counts: finalValidSizes)
  }


  public func getName(_ bodyData: SysexBodyData, index: Int) -> String? {
    guard let bodyData = bodyData.data() as? BodyData else { return nil }
    return patchTruss.getName(bodyData[index]) ?? defaultPatchName(index: index)
  }
  
  public func defaultPatchName(index: Int) -> String {
    "\(patchTruss.defaultName ?? "Patch") \(index + 1)"
  }
  
  public func createEmptyBodyData() throws -> BodyData {
    try (0..<patchCount).map { _ in try patchTruss.createInitBodyData() }
  }
      
  public func createInitBodyData() throws -> BodyData {
    if initFileName.count > 0 {
      guard let dataAsset = PBDataAsset(name: initFileName) else {
        throw SysexTrussError.fileNotFound(msg: "WARNING: Data asset missing for \(displayId)")
      }
      return try parseBodyData(dataAsset.data.bytes())
    }
    else if anyPatchTruss.initFileName.count > 0 {
      let patchBodyData = try patchTruss.createInitBodyData()
      return BodyData(repeating: patchBodyData, count: patchCount)
    }
    else {
      return try createEmptyBodyData()
    }

  }

}


public typealias SingleBankTruss = SomeBankTruss<SinglePatchTruss>
public typealias MultiBankTruss = SomeBankTruss<MultiPatchTruss>

public extension SomeBankTruss {
  
  static func sortAndParseBodyDataWithLocationIndex(_ locationIndex: Int, parseBodyData: @escaping PT.Core.ParseBodyDataFn, patchCount: Int) -> Core.ParseBodyDataFn {
    {
      try SingleBankTrussWerk.singleSortedByteArrays(sysexData: $0, count: patchCount, locationByteIndex: locationIndex).map { try parseBodyData($0) }
    }
  }

}
