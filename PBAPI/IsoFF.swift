
public struct IsoFF {
  public let forward: (Float) -> Float
  public let backward: (Float) -> Float
  
  public init(forward: @escaping (Float) -> Float, backward: @escaping (Float) -> Float) {
    self.forward = forward
    self.backward = backward
  }
}

extension Float {
  public func misoEquals(_ other: Self) -> Bool { self == other }
  public static var outOfRange: Self { -9999 }
}

public extension IsoFF {
  
  static func ident() -> Self {
    .init(
        forward: { $0 },
        backward: { $0 }
    )
  }
  
  /// Multiply
  static func m(_ x: Float) -> Self {
      .init(
          forward: { x * $0 },
          backward: { $0 / x }
      )
  }

  /// Divide by
  static func d(_ x: Float) -> Self {
      .init(
          forward: { $0 / x },
          backward: { $0 * x }
      )
  }

  /// Add
  static func a(_ x: Float) -> Self {
      .init(
          forward: { $0 + x },
          backward: { $0 - x }
      )
  }
  
  /// natural log
  static func ln() -> Self {
    .init(
        forward: { logf($0) },
        backward: { expf($0) }
    )
  }

  static func exp() -> Self {
    .init(
        forward: { expf($0) },
        backward: { logf($0) }
    )
  }
  
  static func pow(base: Float) -> Self {
    let baseLog = logf(base)
    return .init(
        forward: { powf(base, $0) },
        backward: { logf($0) / baseLog }
    )
  }
  
  static func round(_ decPlaces: Int = 0) -> Self {
    let f: (Float) -> Float
    if decPlaces == 0 {
      f = { roundf($0) }
    }
    else {
      let tenner = powf(10, Float(decPlaces))
      f = { roundf($0 * tenner) / tenner }
    }
    return .init(
      forward: f,
      backward: { $0 }
    )
  }

  static func floor(_ decPlaces: Int = 0) -> Self {
    let f: (Float) -> Float
    if decPlaces == 0 {
      f = { floorf($0) }
    }
    else {
      let tenner = powf(10, Float(decPlaces))
      f = { floorf($0 * tenner) / tenner }
    }
    return .init(
      forward: f,
      backward: { $0 }
    )
  }

  /// map 0...1 to a range
  static func unitLerp(_ range: ClosedRange<Float>) -> Self {
    .m(range.upperBound - range.lowerBound) >>> .a(range.lowerBound)
  }
  
  /// map incoming range to 0...1
  static func unitize(_ inRange: ClosedRange<Float>) -> Self {
    .a(-1 * inRange.lowerBound) >>> .m(1 / (inRange.upperBound - inRange.lowerBound))
  }

  /// map range to a range
  static func lerp(in inn: ClosedRange<Float>, out: ClosedRange<Float>) -> Self {
    unitize(inn) >>> unitLerp(out)
  }

  static func lerp(in inn: Float, out: ClosedRange<Float>) -> Self {
    unitize(0...inn) >>> unitLerp(out)
  }

  /// startIndex is the number value that should return the first option string
  static func options(_ opts: [Float], startIndex: Int = 0) -> Self {
    .init(
        forward: {
          let index = Int($0) - startIndex
          guard (0..<opts.count).contains(index) else { return Float.outOfRange }
          return opts[index]
        },
        backward: {
          for opt in opts.enumerated() {
            if opt.element.misoEquals($0) { return Float(opt.offset + startIndex) }
          }
          return .outOfRange
        }
    )
  }

  
  /// Assumes opts are sorted!
  static func lookupFunction(_ opts: [Float], startIndex: Int = 0) -> Self {
    func closest(_ val1: Float, _ val2: Float, _ target: Float) -> Float {
      abs(target - val1) >= abs(val2 - target) ? val2 : val1
    }
    
    return .init(
        forward: {
          let index = Int($0) - startIndex
          guard (0..<opts.count).contains(index) else { return .outOfRange }
          return opts[index]
        },
        backward: { (target) in
          // The linked algo returns the *value* but we want to return the *index*
          // So, modified.
          // https://www.geeksforgeeks.org/find-closest-number-array/
          let n = opts.count
          // Corner cases
          guard target > opts[0] || target < opts[n - 1] else { return .outOfRange }
           
          // Doing binary search
          var i = 0
          var j = n
          var mid = 0

          while i < j {
            mid = (i + j) / 2
     
            if opts[mid] == target { return Float(mid) }
     
            //If target is less than array element, then search in left
            if target < opts[mid] {
              // If target is greater than previous to mid, return closest of two
              if mid > 0 && target > opts[mid - 1] {
                let index = abs(opts[mid] - target) < abs(opts[mid - 1] - target) ? mid : mid - 1
                return Float(index)
              }
              // Repeat for left half
              j = mid
            }
            else {
              // If target is greater than mid
              if mid < n - 1 && target < opts[mid + 1] {
                let index = abs(target - opts[mid]) < abs(opts[mid + 1] - target) ? mid : mid + 1
                return Float(index)
              }
              // Repeat for right half
              i = mid + 1
            }
          }

          // Only single element left after search
          return Float(mid)
        }
    )
  }
  
  
  static func piecewise(breaks: [(Float, Float)]) -> Self {
    guard breaks.count > 1 else { return .a(0) }
    return .switcher((1..<breaks.count).map {
      let low = breaks[$0 - 1]
      let hi = breaks[$0]
      return .range((low.0)...(hi.0), .lerp(in: (low.0)...(hi.0), out: (low.1)...(hi.1)))
    })
  }

  
  /// Exponential regression from Jupyter
  static func exponReg(a: Float, b: Float, c: Float) -> Self {
    .m(b) >>> .exp() >>> .m(a) >>> .a(c)
  }
  
  /// Quadratic regression from Jupyter. neg: true for when you want have a down sloped curve
  static func quadReg(a: Float, b: Float, c: Float, neg: Bool = false) -> Self {
    return .init(
        forward: { (a * $0 * $0) + (b * $0) + c },
        backward: { (-b + (neg ? -1 : 1) * sqrtf(b * b - (4 * a * (c - $0)))) / (2 * a) }
    )
  }

  enum SwitcherCheck {
    case int(Int, Float)
    case range(ClosedRange<Float>, IsoFF)
    case rangeString(ClosedRange<Float>, Float)
  }

  static func switcher(_ checks: [SwitcherCheck], default def: Self? = nil, withBase: Bool = false) -> Self {
    return .init(
      forward: {
        let i = Int($0)
        for check in checks {
          switch check {
          case .int(let checkInt, let constY):
            if i == checkInt { return constY }
          case .range(let checkRange, let iso):
            if checkRange.contains($0) {
              if withBase {
                return iso.forward($0 - checkRange.lowerBound)
              }
              else {
                return iso.forward($0)
              }
            }
          case .rangeString(let checkRange, let s):
            if checkRange.contains($0) { return s }
          }
        }
        return def?.forward($0) ?? Float.outOfRange
      },
      backward: {
        for check in checks {
          switch check {
          case .int(let checkInt, let constY):
            if constY.misoEquals($0) {
              return Float(checkInt)
            }
          case .range(let checkRange, let iso):
            let f = iso.backward($0) + (withBase ? checkRange.lowerBound : 0)
            if checkRange.contains(f) { return f }
          case .rangeString(let checkRange, let s):
            if s.misoEquals($0) {
              return checkRange.lowerBound
            }
          }
        }
        return def?.backward($0) ?? Float.outOfRange
      }
    )
  }
  
}
