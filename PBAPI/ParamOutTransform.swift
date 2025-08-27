
public enum ParamOutTransform {
  
  case patchOut(_ src: SynthPath, _ fn: PatchOutFn)
  case bankOut(_ src: SynthPath, _ fn: BankOutFn)
  case bankNames(_ src: SynthPath, _ path: SynthPath, nameBlock: ((Int, String) -> String)? = nil)

  public typealias PatchOutFn = (_ change: PatchChange, _ patch: AnySysexPatch?) throws -> [Parm]
  public typealias BankOutFn = (_ change: BankChange, _ bank: AnySysexPatchBank?) throws -> SynthPathParam
  
}

