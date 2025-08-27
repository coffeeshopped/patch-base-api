
public enum ParamOutTransform {
  
  case patchOut(_ fn: PatchOutFn)
  case bankOut(_ fn: BankOutFn)
  case bankNames(_ path: SynthPath, nameBlock: ((Int, String) -> String)? = nil)

  public typealias PatchOutFn = (_ change: PatchChange, _ patch: AnySysexPatch?) throws -> [Parm]
  public typealias BankOutFn = (_ change: BankChange, _ bank: AnySysexPatchBank?) throws -> SynthPathParam
  
}

