
public enum SysexBodyData {
  case single(SinglePatchTruss.BodyData)
  case multi(MultiPatchTruss.BodyData)
  case bank([SysexBodyData])
  case json(JSONPatchTruss.BodyData)
  case multiSysex([SynthPath:SysexBodyData])
  
  public func data() -> Any {
    switch self {
    case .single(let d):
      return d
    case .multi(let d):
      return d
    case .bank(let d):
      return d.map { $0.data() }
    case .json(let d):
      return d
    case .multiSysex(let d):
      return d.dict { [$0.key : $0.value] }
    }
  }
  
  static func from(_ data: Any) throws -> Self {
    switch data {
    case let d as SinglePatchTruss.BodyData:
      return .single(d)
    case let d as MultiPatchTruss.BodyData:
      return .multi(d)
    case let d as [SinglePatchTruss.BodyData]:
      return .bank(d.map { .single($0) })
    case let d as [MultiPatchTruss.BodyData]:
      return .bank(d.map { .multi($0) })
    case let d as JSONPatchTruss.BodyData:
      return .json(d)
    case let d as [SynthPath:Any]:
      var dict = MultiSysexTrussBodyData()
      try d.forEach { dict[$0.key] = try from($0.value) }
      return .multiSysex(dict)
    default:
      throw SysexTrussError.incorrectSysexType(msg: "Bad Body data type.")
    }
  }
}

public protocol SysexTruss : Hashable {
  
  associatedtype BodyData
  typealias Core = SysexTrussCore<BodyData>

  var core: Core { get }
  
//  func createSysexible(fileData: [UInt8]?, name: String?) throws -> AnySysexible
  
  /// Part of the protocol so that BankTruss can override to init with patch data if bank asset is missing.
  func createInitBodyData() throws -> BodyData
  
  func createEmptyBodyData() throws -> BodyData

  func sysexBodyData(_ data: BodyData) -> SysexBodyData
}

public extension SysexTruss {
  
  static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.displayId == rhs.displayId
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(displayId)
  }
  
}

public extension SysexTruss {
  
  static func bytes(url: URL) throws -> [UInt8] {
    guard let data = FileManager.default.contents(atPath: url.path) else { throw SysexTrussError.fileNotFound(msg: url.path) }
    return data.bytes()
  }
  
  static func name(fromURL url: URL) -> String {
    url.deletingPathExtension().lastPathComponent
  }
    
  func fetchRequest(_ msg: MidiMessage) -> RxMidi.FetchCommand {
    .requestMsg(msg, .eq(fileDataCount))
  }


}


public extension SysexTruss {
  
  func isBodyDataType(bodyData: SysexBodyData) -> Bool { bodyData.data() is BodyData }
  
  var displayId: String { core.displayId }
    
  var initFileName: String { core.initFileName }
    
  var maxNameCount: Int { core.maxNameCount }
  
  var defaultName: String? { core.defaultName }
  
  var fileDataCount: Int { core.fileDataCount }

  var isValidSize: (Int) -> Bool { { core.isValidSize.check($0) } }

  var isValidFileData: ([UInt8]) -> Bool { { core.isValidFileData.check($0) } }

  var isCompleteFetch: ([UInt8]) -> Bool { { core.isCompleteFetch.check($0) } }

  var createFileData: (BodyData) throws -> [MidiMessage] {
    { try core.createFileData.call($0, nil) }
  }
  
  var parseBodyData: ([UInt8]) throws -> BodyData { { try core.parseBodyData($0) } }
    
  func createInitBodyData() throws -> BodyData {
    // look for an init file, otherwise create zero-ed data
    guard initFileName.count > 0 else {
      return try createEmptyBodyData()
    }

    guard let dataAsset = PBDataAsset(name: initFileName) else {
      throw SysexTrussError.fileNotFound(msg: "WARNING: Data asset missing for \(displayId). Init file name: \(initFileName)")
    }
    
    return try parseBodyData(dataAsset.data.bytes())
  }
  
  func createInitAnyBodyData() throws -> SysexBodyData {
    try sysexBodyData(createInitBodyData())
  }

  func parseAnyBodyData(fileData: [UInt8]) throws -> SysexBodyData {
    try sysexBodyData(parseBodyData(fileData))
  }

  func createFileData(anyBodyData: SysexBodyData) throws -> [MidiMessage] {
    guard let bodyData = anyBodyData.data() as? BodyData else {
      throw SysexTrussError.incorrectSysexType(msg: "Bad body data type!")
    }
    return try createFileData(bodyData)
  }
  
}

