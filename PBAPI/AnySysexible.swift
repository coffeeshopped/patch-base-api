
public protocol AnySysexible {
  var anyTruss: any SysexTruss { get }
  var anyBodyData: SysexBodyData { get }
  var name: String { get set }
  func fileData() throws -> [UInt8]
}

public extension AnySysexible {
    
  var escapedName: String {
    var invalidCharacters = CharacterSet(charactersIn: ":/")
    invalidCharacters.formUnion(.newlines)
    invalidCharacters.formUnion(.illegalCharacters)
    invalidCharacters.formUnion(.controlCharacters)
    return name.components(separatedBy: invalidCharacters).joined(separator: "-")
  }
  
}
