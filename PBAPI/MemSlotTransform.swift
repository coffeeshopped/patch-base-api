
public struct MemSlot : Hashable {
  
  public static let off = Self.init([], 0)
  
  public let path: SynthPath
  public let location: Int
  
  public init(_ path: SynthPath, _ location: Int) {
    self.path = path
    self.location = location
  }
  
  public typealias TransformFn = (Int) throws -> String
  public enum Transform {
    case user(TransformFn)
    case preset(TransformFn, names: [String])
    
    public var fn: TransformFn {
      switch self {
      case .user(let slot):
        return slot
      case .preset(let slot, _):
        return slot
      }
    }
    
    public func slot(_ i: Int) throws -> String { try fn(i) }
  }

}
