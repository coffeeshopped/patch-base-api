
public struct SynthWerk {
  
  public let name: String
  
  public init(_ name: String) {
    self.name = name
  }
  
  
}

public extension SynthWerk {
  
  func id(_ id: String) -> String { "\(name).\(id)" }
  
}
