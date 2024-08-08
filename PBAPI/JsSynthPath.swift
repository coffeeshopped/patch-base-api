import JavaScriptCore

public struct JsSynthPath {
  
  static let decoder = JSONDecoder()
  static let encoder = JSONEncoder()
  
  public static func decode(_ path: Any) -> SynthPath {
    switch path {
    case let s as String:
      return decode(string: s)
    case let a as [Any]:
      return decode(array: a)
    case let path as JSValue:
      if path.isObject, let a = path.toArray() {
        return decode(array: a)
      }
      else if let s = path.toString() {
        return decode(string: s)
      }
    default:
      break
    }
    return []
  }
  
  public static func decode(array: [Any]) -> SynthPath { array.map { $0 as! SynthPathItem } }

  public static func decode(string: String) -> SynthPath {
    let parts: [Any] = string.split(separator: "/").map {
      guard let i = Int($0) else { return "\($0)" }
      return i
    }
    return decode(array: parts)
  }

  public static func encode(_ path: SynthPath) -> String {
    let joined = path.map{
      switch $0 {
      case let i as Int:
        return "\(i)"
      case let s as String:
        return s
      default:
        return "\($0)"
      }
    }.joined(separator: "/")
    return String(joined)
  }
  
}
