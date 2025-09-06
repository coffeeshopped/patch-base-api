
import PBAPI

extension IsoFS : JsParsable {
  
  static let jsRules: [JsParseRule<Self>] = [
    .a("str", [], optional: [String.self], {
      try .str($0.xq(1) ?? "%g")
    }),
    .a("noteName", [String.self], {
      try .noteName(zeroNote: $0.x(1), octave: true)
    }),
    .t(String.self, {
      try .const($0.x())
    }),
    .a("switch", [[SwitcherCheck].self], optional: [IsoFS.self], {
      try .switcher($0.x(1), default: $0.xq(2))
    }),
    .a("baseSwitch", [[SwitcherCheck].self], optional: [IsoFS.self], {
      try .switcher($0.x(1), default: $0.xq(2), withBase: true)
    }),
    .a("concat", [IsoFS.self], { v in
      let isos: [IsoFS] = try (1..<v.arrCount()).map { try v.x($0) }
      return .init { f in
        isos.map { $0.forward(f) }.joined()
      } backward: { s in
        isos.first?.backward(s) ?? .outOfRange
      }
    }),
    .a("units", [String.self], {
      try .unitFormat($0.x(1))
    }),
    .a("@", [[String].self], {
      try .options($0.x(1))
    }),
    .a(">", [IsoFF.self], optional: [IsoFS.self], {
      var floatOut = true
      var isoFMerge: IsoFF?
      var isoSMerge: IsoFS?
      var skipFirst = true
      try $0.forEach {
        if skipFirst {
          skipFirst = false
          return
        }
        
        if floatOut {
          // first see if isoF
          if let isoF: IsoFF = try? $0.x() {
            if let oldIsoF = isoFMerge {
              isoFMerge = oldIsoF >>> isoF
            }
            else {
              isoFMerge = isoF
            }
          }
          else {
            // if not, see if isoS
            if let isoFMerge = isoFMerge {
              isoSMerge = try isoFMerge >>> $0.x()
            }
            else {
              isoSMerge = try $0.x()
            }
            floatOut = false
          }
        }
        else {
          // only S->S now
          // TODO: here is where String->String isos would be... IsoSS?
        }
      }

      if let isoSMerge = isoSMerge {
        return isoSMerge
      }
      else if let isoFMerge = isoFMerge {
        // if all the isos were float-out, then tack on a string iso at the end
        return isoFMerge >>> .str()
      }
      else {
        return .str()
      }
    }),
    .t(IsoFF.self, {
      // last check: see if it's an IsoFF and if so, parse and pipe to String
      let ff: IsoFF = try $0.x()
      return ff >>> .str()
    }),
  ]
  
}

extension IsoFS.SwitcherCheck: JsParsable {
  
  static let jsRules: [JsParseRule<Self>] = [
    .arr([Int.self, String.self], { try .int($0.x(0), $0.x(1)) }),
    .arr([ClosedRange<Float>.self, String.self], { try .rangeString($0.x(0), $0.x(1)) }),
    .arr([ClosedRange<Float>.self, IsoFS.self], { try .range($0.x(0), $0.x(1)) }),
  ]
  
}
