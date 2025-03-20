
import PBAPI

extension IsoFS : JsParsable {
  
  static let jsRules: [JsParseRule<Self>] = [
    .a(["str", ".s?"], {
      let format: String = try $0.xq(1) ?? "%g"
      return .str(format)
    }),
    .a(["noteName", ".s"], {
      try .noteName(zeroNote: $0.x(1), octave: true)
    }),
    .s(".s", {
      try .const($0.x())
    }),
    .a(["switch", ".a", ".x?"], {
      try .switcher($0.x(1), default: $0.xq(2))
    }),
    .a(["concat"], { v in
      let isos: [IsoFS] = try (1..<v.arrCount()).map { try v.x($0) }
      return .init { f in
        isos.map { $0.forward(f) }.joined()
      } backward: { s in
        isos.first?.backward(s) ?? .outOfRange
      }
    }),
    .a([">"], {
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
      guard let isoSMerge = isoSMerge else { throw JSError.error(msg: "No IsoFS found in iso array") }
      return isoSMerge
    }),
    .s(".x", {
      // last check: see if it's an IsoFF and if so, parse and pipe to String
      let ff: IsoFF = try $0.x()
      return ff >>> .str()
    }),
  ]
}

extension IsoFS.SwitcherCheck: JsParsable {
  
  static let jsRules: [JsParseRule<Self>] = [
    .a([".n", ".s"], { try .int($0.x(0), $0.x(1)) }),
    .a([".a", ".s"], {
      let rngArr = try $0.arr(0)
      let min: Float = try rngArr.x(0)
      let max: Float = try rngArr.x(1) - 1
      return try .rangeString(min...max, $0.x(1))
    }),
    .a([".a", ".x"], {
      let rngArr = try $0.arr(0)
      let min: Float = try rngArr.x(0)
      let max: Float = try rngArr.x(1) - 1
      return try .range(min...max, $0.x(1))
    }),
  ]
}
