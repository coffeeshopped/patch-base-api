
import Foundation

public enum ByteTransform {
  
  case fn((_ b: [UInt8], _ e: AnySynthEditor?) throws -> [UInt8])
  case b((_ b: [UInt8]) throws -> [UInt8])
  case e((_ e: AnySynthEditor?) throws -> [UInt8])
  case const([UInt8])
  case ident

  public func call(_ b: [UInt8], _ e: AnySynthEditor?) throws -> [UInt8] {
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
      return b
    }
  }
}
