
import PBAPI

enum JsSysex {
  
  private static let combinedRules: [JsParseTransform<any SysexTruss>] = [
    SinglePatchTruss.jsParsers.anyTrussRules(),
    SingleBankTruss.jsParsers.anyTrussRules(),
    JSONPatchTruss.jsParsers.anyTrussRules(),
    MultiPatchTruss.jsParsers.anyTrussRules(),
    MultiBankTruss.jsParsers.anyTrussRules(),
  ].flatMap({ $0 })
  
  static let trussRules: JsParseTransformSet<any SysexTruss> = .init(combinedRules, "truss")
  
}
