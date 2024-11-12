
public enum SynthPathMap {
  case fn((_ p: SynthPath) throws -> SynthPath?)
  case removePrefix(_ f: SynthPath)
  case from(_ i: Int)
  
  public func call(_ p: SynthPath) throws -> SynthPath? {
    switch self {
    case .fn(let fn):
      return try fn(p)
    case .removePrefix(let pre):
      return p.starts(with: pre) ? p.subpath(from: p.count) : nil
    case .from(let i):
      return Array(p.suffix(from: i))
    }
  }
}
