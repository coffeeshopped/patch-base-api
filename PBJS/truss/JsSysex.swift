
import PBAPI

enum JsSysex {
    
  static let trussRules: [NuJsParseRule<any SysexTruss>] = [
    SinglePatchTruss.nuJsRules.map { $0.anyTrussRule() },
    SingleBankTruss.nuJsRules.map { $0.anyTrussRule() },
    JSONPatchTruss.nuJsRules.map { $0.anyTrussRule() },
    MultiPatchTruss.nuJsRules.map { $0.anyTrussRule() },
    MultiBankTruss.nuJsRules.map { $0.anyTrussRule() },
  ].flatMap({ $0 })
  
}

extension NuJsParseRule where Output: SysexTruss {
  
  func anyTrussRule() -> NuJsParseRule<any SysexTruss> {
    .init(match, { try transform($0) as any SysexTruss })
  }
}
