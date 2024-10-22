
public enum ValidSizeFn {
  case fn((Int) -> Bool)
  case const(Bool)
  
  func check(_ size: Int) -> Bool {
    switch self {
    case .fn(let fn):
      return fn(size)
    case .const(let b):
      return b
    }
  }
}

public enum ValidDataFn {
  case fn(([UInt8]) -> Bool)
  case const(Bool)

  func check(_ data: [UInt8]) -> Bool {
    switch self {
    case .fn(let fn):
      return fn(data)
    case .const(let b):
      return b
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
}
