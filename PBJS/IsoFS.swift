
import PBAPI

extension IsoFS : JsParsable {
  
  static let jsParsers: JsParseTransformSet<Self> = try! .init([
    (["str", ".s?"], {
      let format: String = try $0.xq(1) ?? "%g"
      return .str(format)
    }),
    (["noteName", ".s"], {
      try .noteName(zeroNote: $0.x(1), octave: true)
    }),
    (".s", {
      try .const($0.x())
    }),
    (["concat"], { v in
      let isos: [IsoFS] = try (1..<v.arrCount()).map { try v.x($0) }
      return .init { f in
        isos.map { $0.forward(f) }.joined()
      } backward: { s in
        isos.first?.backward(s) ?? .outOfRange
      }
    }),
    ([">"], {
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
  ])
}

