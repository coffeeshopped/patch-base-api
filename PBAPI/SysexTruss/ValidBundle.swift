
public enum ValidSizeFn {
  case size(Int)
  case sizes([Int])
  case fn((Int) -> Bool)
  case const(Bool)
  
  func check(_ size: Int) -> Bool {
    switch self {
    case .size(let s):
      return s == size
    case .sizes(let s):
      return s.contains(size)
    case .fn(let fn):
      return fn(size)
    case .const(let b):
      return b
    }
  }
}

public enum ValidDataFn {
  case size(Int)
  case sizes([Int])
  case fn(([UInt8]) -> Bool)
  case const(Bool)

  func check(_ data: [UInt8]) -> Bool {
    switch self {
    case .size(let s):
      return s == data.count
    case .sizes(let s):
      return s.contains(data.count)
    case .fn(let fn):
      return fn(data)
    case .const(let b):
      return b
    }
  }
}

public extension ValidDataFn {
  
  static func withValidSize(_ validSizeFn: ValidSizeFn) -> ValidDataFn {
    switch validSizeFn {
    case .size(let s):
      return .size(s)
    case .sizes(let s):
      return .sizes(s)
    case .const(let b):
      return .const(b)
    case .fn(let fn):
      return .fn({ fn($0.count) })
    }
  }

}

public struct ValidBundle {
  let validSize: ValidSizeFn
  let validData: ValidDataFn
  let completeFetch: ValidDataFn
  
  public init(validSize: ValidSizeFn, validData: ValidDataFn, completeFetch: ValidDataFn) {
    self.validSize = validSize
    self.validData = validData
    self.completeFetch = completeFetch
  }
  
  public init(sizes: [Int]) {
    validSize = .sizes(sizes)
    validData = .sizes(sizes)
    completeFetch = .sizes(sizes)
  }
  
  public init(size: Int) {
    validSize = .size(size)
    validData = .size(size)
    completeFetch = .size(size)
  }

}
