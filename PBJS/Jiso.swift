
//import JavaScriptCore
//
//
///*
// This is all just a copy of Miso, but without generics and all so that
// it can be represented in Obj-C, and thus exported to Javascript
// */
//
//
//public class JisoFF : NSObject {
//  public let forward: (Float) -> Float
//  public let backward: (Float) -> Float
//  
//  init(forward: @escaping (Float) -> Float, backward: @escaping (Float) -> Float) {
//    self.forward = forward
//    self.backward = backward
//  }
//}
//
//public class JisoFS : NSObject {
//  public let forward: (Float) -> String
//  public let backward: (String) -> Float
//
//  init(forward: @escaping (Float) -> String, backward: @escaping (String) -> Float) {
//    self.forward = forward
//    self.backward = backward
//  }
//  
//  func iso() -> Iso<Float,String> {
//    return .init {
//      self.forward($0)
//    } backward: {
//      self.backward($0)
//    }
//
//  }
//}
//
//public extension JisoFS {
//
//  func pvm() -> ParamValueMapper {
//    (
//      format: { self.forward(Float($0)) },
//      parse: { Int(round(self.backward($0))) }
//    )
//  }
//}
//
//@objc protocol JisoExport : JSExport {
//  static func m(_ x: Float) -> JisoFF
//  static func d(_ x: Float) -> JisoFF
//  static func a(_ x: Float) -> JisoFF
//  static func ln() -> JisoFF
//  static func exp() -> JisoFF
//  static func pow(base: Float) -> JisoFF
//  
//  static func str(_ format: String) -> JisoFS
//  
//  static func noteName(_ zeroNote: String, _ octave: JSValue) -> JisoFS
//
//}
//
//public class Jiso : NSObject, JisoExport {
//
//  /// Multiply
//  public static func m(_ x: Float) -> JisoFF {
//      return .init(
//          forward: { x * $0 },
//          backward: { $0 / x }
//      )
//  }
//
//  /// Divide by
//  public static func d(_ x: Float) -> JisoFF {
//      return .init(
//          forward: { $0 / x },
//          backward: { $0 * x }
//      )
//  }
//
//  /// Add
//  public static func a(_ x: Float) -> JisoFF {
//      return .init(
//          forward: { $0 + x },
//          backward: { $0 - x }
//      )
//  }
//
//  /// natural log
//  public static func ln() -> JisoFF {
//    return .init(
//        forward: { logf($0) },
//        backward: { expf($0) }
//    )
//  }
//
//  public static func exp() -> JisoFF {
//    return .init(
//        forward: { expf($0) },
//        backward: { logf($0) }
//    )
//  }
//
//  public static func pow(base: Float) -> JisoFF {
//    let baseLog = logf(base)
//    return .init(
//        forward: { powf(base, $0) },
//        backward: { logf($0) / baseLog }
//    )
//  }
//
//  @objc public class func str(_ format: String = "%g") -> JisoFS {
//    return .init(
//        forward: {
//          return String(format: format, $0)
//        },
//        backward: {
//          let scanner = Scanner(string: $0)
//          var f: Float = 0
//          scanner.scanFloat(&f)
//          return f
//        }
//    )
//  }
//
//  public static func unitFormat(_ format: String) -> JisoFS {
//    return .init(
//        forward: {
//          return String(format: "%g%@", $0, format)
//        },
//        backward: {
//          // first, see if unit string is present
//          if $0.lowercased().range(of: "\\d+\\.?\\d*\\s*\(format.lowercased())", options: .regularExpression) != nil {
//            let scanner = Scanner(string: $0)
//            var f: Float = 0
//            scanner.scanFloat(&f)
//            return f
//          }
//          else if let num = Float($0) {
//            // if not, see if there's just a number (no unit)
//            return num
//          }
//          // if not, not found
//          return Float.outOfRange
//        }
//    )
//  }
//
//  public static func round(_ decPlaces: Int = 0) -> JisoFF {
//    let tenner = powf(10, Float(decPlaces))
//    return .init(
//      forward: {
//        if decPlaces == 0 {
//          return roundf($0)
//        }
//        else {
//          return roundf($0 * tenner) / tenner
//        }
//      },
//      backward: { $0 }
//    )
//  }
//
//  public static func floor(_ decPlaces: Int = 0) -> JisoFF {
//    let tenner = powf(10, Float(decPlaces))
//    return .init(
//      forward: {
//        if decPlaces == 0 {
//          return floorf($0)
//        }
//        else {
//          return floorf($0 * tenner) / tenner
//        }
//      },
//      backward: { $0 }
//    )
//  }
//
//  /// map 0...1 to a range
//  public static func unitLerp(_ range: ClosedRange<Float>) -> JisoFF {
//    return Jiso.m(range.upperBound - range.lowerBound) >>> Jiso.a(range.lowerBound)
//  }
//
//  /// map incoming range to 0...1
//  public static func unitize(_ inRange: ClosedRange<Float>) -> JisoFF {
//    return Jiso.a(-1 * inRange.lowerBound) >>> Jiso.m(1 / (inRange.upperBound - inRange.lowerBound))
//  }
//
//  /// map range to a range
//  public static func lerp(in inn: ClosedRange<Float>, out: ClosedRange<Float>) -> JisoFF {
//    return unitize(inn) >>> unitLerp(out)
//  }
//
//  public static func lerp(in inn: Float, out: ClosedRange<Float>) -> JisoFF {
//    return unitize(0...inn) >>> unitLerp(out)
//  }
//
//  /// startIndex is the number value that should return the first option string
//  public static func optionsF(_ opts: [Float], startIndex: Int = 0) -> JisoFF {
//    return .init(
//        forward: {
//          let index = Int($0) - startIndex
//          guard (0..<opts.count).contains(index) else { return .outOfRange }
//          return opts[index]
//        },
//        backward: {
//          for opt in opts.enumerated() {
//            if opt.element.misoEquals($0) { return Float(opt.offset + startIndex) }
//          }
//          return .outOfRange
//        }
//    )
//  }
//
//  public static func optionsS(_ opts: [String], startIndex: Int = 0) -> JisoFS {
//    return .init(
//        forward: {
//          let index = Int($0) - startIndex
//          guard (0..<opts.count).contains(index) else { return .outOfRange }
//          return opts[index]
//        },
//        backward: {
//          for opt in opts.enumerated() {
//            if opt.element.misoEquals($0) { return Float(opt.offset + startIndex) }
//          }
//          return .outOfRange
//        }
//    )
//  }
//
//  /// Assumes opts are sorted!
//  public static func lookupFunction(_ opts: [Float], startIndex: Int = 0) -> JisoFF {
//    func closest(_ val1: Float, _ val2: Float, _ target: Float) -> Float {
//      return abs(target - val1) >= abs(val2 - target) ? val2 : val1
//    }
//
//    return .init(
//        forward: {
//          let index = Int($0) - startIndex
//          guard (0..<opts.count).contains(index) else { return .outOfRange }
//          return opts[index]
//        },
//        backward: { (target) in
//          // The linked algo returns the *value* but we want to return the *index*
//          // So, modified.
//          // https://www.geeksforgeeks.org/find-closest-number-array/
//          let n = opts.count
//          // Corner cases
//          guard target > opts[0] || target < opts[n - 1] else { return .outOfRange }
//
//          // Doing binary search
//          var i = 0
//          var j = n
//          var mid = 0
//
//          while i < j {
//            mid = (i + j) / 2
//
//            if opts[mid] == target { return Float(mid) }
//
//            //If target is less than array element, then search in left
//            if target < opts[mid] {
//              // If target is greater than previous to mid, return closest of two
//              if mid > 0 && target > opts[mid - 1] {
//                let index = abs(opts[mid] - target) < abs(opts[mid - 1] - target) ? mid : mid - 1
//                return Float(index)
//              }
//              // Repeat for left half
//              j = mid
//            }
//            else {
//              // If target is greater than mid
//              if mid < n - 1 && target < opts[mid + 1] {
//                let index = abs(target - opts[mid]) < abs(opts[mid + 1] - target) ? mid : mid + 1
//                return Float(index)
//              }
//              // Repeat for right half
//              i = mid + 1
//            }
//          }
//
//          // Only single element left after search
//          return Float(mid)
//        }
//    )
//  }
//
//
//  public static func piecewise(breaks: [(Float, Float)]) -> JisoFF {
//    guard breaks.count > 1 else { return Jiso.a(0) }
//    return switcherF((1..<breaks.count).map {
//      let low = breaks[$0 - 1]
//      let hi = breaks[$0]
//      return .range((low.0)...(hi.0), Jiso.lerp(in: (low.0)...(hi.0), out: (low.1)...(hi.1)))
//    })
//  }
//
//  /// octave: whether to include octave numbers
//  public static func noteName(_ zeroNote: String, _ octave: JSValue) -> JisoFS {
//
//    let notes = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
//    func parseNote(_ str: String) -> (Int, Int) {
//      var note = String(str[...str.startIndex]).uppercased()
//      let off1 = str.index(after: str.startIndex)
//      let char2 = String(str[off1...off1])
//      let oct: String
//      if char2 == "#" {
//        note = note + "#"
//        let off2 = str.index(after: off1)
//        oct = String(str[off2...])
//      }
//      else {
//        oct = String(str[off1...])
//      }
//      let n = notes.firstIndex(of: note) ?? 0
//      let o = Int(oct) ?? 0
//      return (n, o)
//    }
//
//    // undefined -> true
//    if octave.isUndefined || octave.toBool() {
//      let parsed = parseNote(zeroNote)
//      let noteOff = parsed.0
//      let zeroOct = parsed.1
//      return .init(
//          forward: {
//            let i = Int($0)
//            let noteIndex = (i + noteOff) % 12
//            let oct = (i / 12) + zeroOct
//            return "\(notes[noteIndex])\(oct)"
//          },
//          backward: {
//            let parsed = parseNote($0)
//            let n = parsed.0
//            let o = parsed.1
//            return Float(((o - zeroOct) * 12) + (n - noteOff))
//          }
//      )
//    }
//    else {
//      let noteOff = notes.firstIndex(of: zeroNote) ?? 0
//      return .init(
//          forward: {
//            let i = Int($0)
//            let noteIndex = (i + noteOff) % 12
//            return "\(notes[noteIndex])"
//          },
//          backward: {
//            let parsed = notes.firstIndex(of: $0) ?? 0
//            return Float(parsed - noteOff)
//          }
//      )
//    }
//  }
//
//  /// Exponential regression from Jupyter
//  public static func exponReg(a: Float, b: Float, c: Float) -> JisoFF {
//    return Jiso.m(b) >>> Jiso.exp() >>> Jiso.m(a) >>> Jiso.a(c)
//  }
//
//  /// Quadratic regression from Jupyter. neg: true for when you want have a down sloped curve
//  public static func quadReg(a: Float, b: Float, c: Float, neg: Bool = false) -> JisoFF {
//    return .init(
//        forward: { (a * $0 * $0) + (b * $0) + c },
//        backward: { (-b + (neg ? -1 : 1) * sqrtf(b * b - (4 * a * (c - $0)))) / (2 * a) }
//    )
//  }
//
//  public enum SwitcherCheckF {
//    case int(Int, Float)
//    case range(ClosedRange<Float>, JisoFF)
//    case rangeString(ClosedRange<Float>, Float)
//  }
//
//  public enum SwitcherCheckS {
//    case int(Int, String)
//    case range(ClosedRange<Float>, JisoFS)
//    case rangeString(ClosedRange<Float>, String)
//  }
//
//  public static func switcherF(_ checks: [SwitcherCheckF], default def: JisoFF? = nil) -> JisoFF {
//    return .init(
//      forward: {
//        let i = Int($0)
//        for check in checks {
//          switch check {
//          case .int(let checkInt, let constY):
//            if i == checkInt { return constY }
//          case .range(let checkRange, let iso):
//            if checkRange.contains($0) { return iso.forward($0) }
//          case .rangeString(let checkRange, let s):
//            if checkRange.contains($0) { return s }
//          }
//        }
//        return def?.forward($0) ?? .outOfRange
//      },
//      backward: {
//        for check in checks {
//          switch check {
//          case .int(let checkInt, let constY):
//            if constY.misoEquals($0) {
//              return Float(checkInt)
//            }
//          case .range(let checkRange, let iso):
//            let f = iso.backward($0)
//            if checkRange.contains(f) { return f }
//          case .rangeString(let checkRange, let s):
//            if s.misoEquals($0) {
//              return checkRange.lowerBound
//            }
//          }
//        }
//        return def?.backward($0) ?? .outOfRange
//      }
//    )
//  }
//
//  public static func switcherS(_ checks: [SwitcherCheckS], default def: JisoFS? = nil) -> JisoFS {
//    return .init(
//      forward: {
//        let i = Int($0)
//        for check in checks {
//          switch check {
//          case .int(let checkInt, let constY):
//            if i == checkInt { return constY }
//          case .range(let checkRange, let iso):
//            if checkRange.contains($0) { return iso.forward($0) }
//          case .rangeString(let checkRange, let s):
//            if checkRange.contains($0) { return s }
//          }
//        }
//        return def?.forward($0) ?? .outOfRange
//      },
//      backward: {
//        for check in checks {
//          switch check {
//          case .int(let checkInt, let constY):
//            if constY.misoEquals($0) {
//              return Float(checkInt)
//            }
//          case .range(let checkRange, let iso):
//            let f = iso.backward($0)
//            if checkRange.contains(f) { return f }
//          case .rangeString(let checkRange, let s):
//            if s.misoEquals($0) {
//              return checkRange.lowerBound
//            }
//          }
//        }
//        return def?.backward($0) ?? .outOfRange
//      }
//    )
//  }
//  /// msec in. Formatted string out
//  public static func msSec(round: Int) -> JisoFS {
//    return switcherS([
//      .range(0...999, Jiso.round(round) >>> unitFormat("ms"))
//    ], default: m(0.001) >>> Jiso.round(round) >>> unitFormat("s"))
//  }
//
//  /// Hz in. Formatted string out
//  public static func hzKhz(round: Int) -> JisoFS {
//    return switcherS([
//      .range(0...999, Jiso.round(round) >>> unitFormat("Hz"))
//    ], default: m(0.001) >>> Jiso.round(round) >>> unitFormat("kHz"))
//  }
//
//}
//
//infix operator >>>: MultiplicationPrecedence
//
//public func >>>(_ lhs: JisoFF, _ rhs: JisoFF) -> JisoFF {
//  .init(
//    forward: { a in rhs.forward(lhs.forward(a)) },
//    backward: { c in lhs.backward(rhs.backward(c)) }
//  )
//}
//
//public func >>>(_ lhs: JisoFF, _ rhs: JisoFS) -> JisoFS {
//  .init(
//    forward: { a in rhs.forward(lhs.forward(a)) },
//    backward: { c in lhs.backward(rhs.backward(c)) }
//  )
//}
