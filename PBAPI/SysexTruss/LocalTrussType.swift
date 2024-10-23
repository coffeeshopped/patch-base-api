
public extension SynthPath {
  
//  static let global: SynthPath = [.global]
//  static let voice: SynthPath = [.voice]
//  static let perf: SynthPath = [.perf]
//  static let fullPerf: SynthPath = [.extra, .perf]
//  static let rhythm: SynthPath = [.rhythm]
//  static let fx: SynthPath = [.fx]
//  static let backup: SynthPath = [.backup]
//  static func bank(_ p: SynthPath) -> Self { [.bank] + p }

//  case other(String)
//  case deviceId
//  case compact(LocalTrussType) // Yamaha. the compact version of some truss.
  
  private static func description(_ path: SynthPath) -> String {
    switch path {
    case [.voice]:
      return "Patch"
    case [.perf]:
      return "Performance"
    case [.extra, .perf]:
      return "Full Performance"
    case [.fx]:
      return "FX"
//    case .other(let t):
//      return t
    case [.deviceId]:
      return "Device Id"
//    case .compact(let sub):
//      return "Compact \(sub.description())"
    default:
      return (path.map {
        switch $0 {
        case .i(let i):
          return i < 0 ? "neg\(-i)" : "\(i)"
        default:
          return "\($0)"
        }
      }).joined(separator: " ").capitalized
    }
  }
  
  static func pluralize(_ s: String) -> String {
    // if the string ends in "*", don't pluralize, just remove the *
    guard !s.hasSuffix("*") else { return String(s.dropLast()) }
    
    switch s {
    case "Patch":
      return "Patches"
    default:
      return "\(s)s"
    }
  }
  
  // some cases have legacy directories.
  func directory(_ desc: (SynthPath) -> String?) -> String {
    // first, pull out numbers.
    let noNums = filter { item in
      switch item {
      case .i(_):
        return false
      default:
        return true
      }
    }

    // first, see if passed in func gives a match
    if let d = desc(noNums) {
      return Self.pluralize(d)
    }
    // if not, run bank filter with passed in func
    if noNums.contains(.bank) {
      if noNums == [.bank, .voice] {
        return "Voice Banks"
      }

      // remove bank
      let filtered = noNums.filter { $0 != .bank }
      var d = desc(filtered) ?? Self.description(filtered)
      // remove any trailing *
      if d.hasSuffix("*") {
        d = String(d.dropLast())
      }
      if d == "Patch" {
        d = "Voice"
      }
      return "\(d) Banks"
    }

    // finally, return defaults
    
    switch self {
    case [.global]:
      return "Global"
    case [.rhythm]:
      return "Rhythm"
    case [.fx]:
      return "FX"
    case [.deviceId]:
      return "Device Id"
    default:
      let singular = Self.description(noNums)
      return Self.pluralize(singular)
    }
  }

}

/**
 What am I looking for?

 On the one hand, a displayId for each truss that is short to specify, but gives a clear indication of the specific truss (for debugging), and that is probably globally unique for each truss
 e.g. blofeld.voice

 The local type probably shouldn't be *within* the truss since it's particular to the editor it's being used in.
 E.g. TX81Z VCED data. For the TX81Z, it's a subpatch for the "voice" multi-patch
 But for the DX100, VCED *is* the voice patch itself (and thus is stored in the Patches directory).
 */
