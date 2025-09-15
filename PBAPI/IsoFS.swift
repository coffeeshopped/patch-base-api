
public struct IsoFS {
  public let forward: (Float) -> String
  public let backward: (String) -> Float
  
  public init(forward: @escaping (Float) -> String, backward: @escaping (String) -> Float) {
    self.forward = forward
    self.backward = backward
  }
}

extension String {
  public func misoEquals(_ other: Self) -> Bool { lowercased() == other.lowercased() }
  public static var outOfRange: Self { "?" }
}

public extension IsoFS {
  
  static func str(_ format: String = "%g") -> Self {
    return .init(
        forward: {
          return String(format: format, $0)
        },
        backward: {
          let scanner = Scanner(string: $0)
          var f: Float = 0
          scanner.scanFloat(&f)
          return f
        }
    )
  }
  
  static func unitFormat(_ format: String) -> Self {
    return .init(
        forward: {
          return String(format: "%g%@", $0, format)
        },
        backward: {
          // first, see if unit string is present
          if $0.lowercased().range(of: "\\d+\\.?\\d*\\s*\(format.lowercased())", options: .regularExpression) != nil {
            let scanner = Scanner(string: $0)
            var f: Float = 0
            scanner.scanFloat(&f)
            return f
          }
          else if let num = Float($0) {
            // if not, see if there's just a number (no unit)
            return num
          }
          // if not, not found
          return Float.outOfRange
        }
    )
  }
  
  static func options(_ opts: [String], startIndex: Int = 0) -> Self {
    return .init(
        forward: {
          let index = Int($0) - startIndex
          guard (0..<opts.count).contains(index) else { return String.outOfRange }
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
  
  static func const(_ s: String) -> Self {
    .init { _ in
      s
    } backward: { _ in
      Float.outOfRange
    }
  }
  
  /// octave: whether to include octave numbers
  static func noteName(zeroNote: String, octave: Bool = true) -> Self {
    
    let notes = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
    func parseNote(_ str: String) -> (Int, Int) {
      var note = String(str[...str.startIndex]).uppercased()
      let off1 = str.index(after: str.startIndex)
      let oct: String
      if str.count < 2 {
        oct = "0"
      }
      else {
        let char2 = String(str[off1...off1])
        if char2 == "#" {
          note = note + "#"
          let off2 = str.index(after: off1)
          oct = String(str[off2...])
        }
        else {
          oct = String(str[off1...])
        }
      }
      let n = notes.firstIndex(of: note) ?? 0
      let o = Int(oct) ?? 0
      return (n, o)
    }
    
    if octave {
      let parsed = parseNote(zeroNote)
      let noteOff = parsed.0
      let zeroOct = parsed.1
      return .init(
          forward: {
            let i = Int($0)
            let noteIndex = (i + noteOff) % 12
            let oct = (i / 12) + zeroOct
            return "\(notes[noteIndex])\(oct)"
          },
          backward: {
            let parsed = parseNote($0)
            let n = parsed.0
            let o = parsed.1
            return Float(((o - zeroOct) * 12) + (n - noteOff))
          }
      )
    }
    else {
      let noteOff = notes.firstIndex(of: zeroNote) ?? 0
      return .init(
          forward: {
            let i = Int($0)
            let noteIndex = (i + noteOff) % 12
            return "\(notes[noteIndex])"
          },
          backward: {
            let parsed = notes.firstIndex(of: $0) ?? 0
            return Float(parsed - noteOff)
          }
      )
    }
  }
  
  enum SwitcherCheck {
    case int(Int, String)
    case range(ClosedRange<Float>, IsoFS)
    case rangeConst(ClosedRange<Float>, String)
  }
  
  static func switcher(_ checks: [SwitcherCheck], default def: Self? = nil, withBase: Bool = false) -> Self {
    .init(
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
          case .rangeConst(let checkRange, let s):
            if checkRange.contains($0) { return s }
          }
        }
        return def?.forward($0) ?? .outOfRange
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
          case .rangeConst(let checkRange, let s):
            if s.misoEquals($0) {
              return checkRange.lowerBound
            }
          }
        }
        return def?.backward($0) ?? .outOfRange
      }
    )
  }
  
  /// msec in. Formatted string out
  static func msSec(round: Int) -> Self {
    switcher([
      .range(0...999, .round(round) >>> .unitFormat("ms"))
    ], default: .m(0.001) >>> .round(round) >>> .unitFormat("s"))
  }

  /// Hz in. Formatted string out
  static func hzKhz(round: Int) -> Self {
    switcher([
      .range(0...999, .round(round) >>> .unitFormat("Hz"))
    ], default: .m(0.001) >>> .round(round) >>> .unitFormat("kHz"))
  }
}
