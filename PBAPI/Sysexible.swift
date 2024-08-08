
public protocol Sysexible : AnyObject {
  
  init()
  init(data: Data)
  init(url: URL)
  
  func copy() -> Self

  static var initFileName: String { get }
  
  func fileData() -> Data
  
  static var fileDataCount: Int { get }
  static func isValid(fileSize: Int) -> Bool
  static func isValid(sysex: Data) -> Bool
  static func isCompleteFetch(sysex: Data) -> Bool
  
  var name: String { get set }
  var escapedName: String { get }
  
  static var maxNameCount: Int { get }
  
  #if os(macOS)
//  static func pasteboardType() -> PBPasteboard.PasteboardType
  #endif
}

public extension Sysexible {
  
  init() {
    let data: Data
    if let dataAsset = PBDataAsset(name: Self.initFileName) {
      data = dataAsset.data
    }
    else {
      data = Data([UInt8](repeating: 0, count: Self.fileDataCount))
      print("WARNING: Data asset missing for \(Self.self)")
    }

    self.init(data: data)
  }
  
  init(url: URL) {
    if let data = FileManager.default.contents(atPath: url.path) {
      self.init(data: data)
    }
    else {
      self.init()
    }

    // set name here (from URL) if this is a sysexible type that doesn't store name
    if name.count == 0 {
      name = url.deletingPathExtension().lastPathComponent
    }
  }
  
  static func isValid(fileSize: Int) -> Bool {
    return fileSize == fileDataCount
  }

  static func isValid(sysex: Data) -> Bool {
    return isValid(fileSize: sysex.count)
  }
  
  static func isCompleteFetch(sysex: Data) -> Bool {
    return isValid(fileSize: sysex.count)
  }
  
  var escapedName: String {
    var invalidCharacters = CharacterSet(charactersIn: ":/")
    invalidCharacters.formUnion(.newlines)
    invalidCharacters.formUnion(.illegalCharacters)
    invalidCharacters.formUnion(.controlCharacters)
    return name.components(separatedBy: invalidCharacters).joined(separator: "-")
  }

  
}

public protocol ChannelizedSysexible : Sysexible {
  func sysexData(channel: Int) -> Data
}
