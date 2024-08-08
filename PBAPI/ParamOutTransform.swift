
public enum ParamOutTransform {
  
  public typealias PatchOutFn = (_ change: NuPatchChange, _ patch: AnySysexPatch?) -> SynthPathParam
  public typealias BankOutFn = (_ change: NuBankChange, _ bank: AnySysexPatchBank?) -> SynthPathParam

  case patchOut(_ src: SynthPath, _ fn: PatchOutFn)
  case bankOut(_ src: SynthPath, _ fn: BankOutFn)
  case bankNames(_ src: SynthPath, _ path: SynthPath, nameBlock: ((Int, String) -> String)? = nil)
  
}

