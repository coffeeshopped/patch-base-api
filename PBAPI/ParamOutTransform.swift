
public struct ParamOutTransform {
  
  public let path: SynthPath
  public let transform: Transform
  
  public init(_ path: SynthPath, _ transform: Transform) {
    self.path = path
    self.transform = transform
  }
  
  public typealias PatchOutFn = (_ change: PatchChange, _ patch: AnySysexPatch?) throws -> SynthPathParam
  public typealias BankOutFn = (_ change: BankChange, _ bank: AnySysexPatchBank?) throws -> SynthPathParam

  public enum Transform {
    case patchOut(_ src: SynthPath, _ fn: PatchOutFn)
    case bankOut(_ src: SynthPath, _ fn: BankOutFn)
    case bankNames(_ src: SynthPath, _ path: SynthPath, nameBlock: ((Int, String) -> String)? = nil)
  }
  
}

