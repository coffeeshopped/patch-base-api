
import PBAPI

enum JsSysex {
    
  static let trussRules: [JsParseRule<any SysexTruss>] = [
    SinglePatchTruss.jsRules.map { $0.anyTrussRule() },
    SingleBankTruss.jsRules.map { $0.anyTrussRule() },
    JSONPatchTruss.jsRules.map { $0.anyTrussRule() },
    MultiPatchTruss.jsRules.map { $0.anyTrussRule() },
    MultiBankTruss.jsRules.map { $0.anyTrussRule() },
  ].flatMap({ $0 })
  
}

extension JsParseRule where Output: SysexTruss {
  
  func anyTrussRule() -> JsParseRule<any SysexTruss> {
    .init(match, { try transform($0) as any SysexTruss }, "anyTruss")
  }
}
