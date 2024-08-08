
public indirect enum NuMultiSysexChange : Change {
  public typealias Sysex = AnyMultiSysexible
  
  case noop
  case replace(AnyMultiSysexible)
  case patch(SynthPath, NuPatchChange)
  case bank(SynthPath, NuBankChange)
  case patchSwap(SynthPath, SynthPath) // across banks! last item is i(index)
  case nameChange(String)
  case push
  
  public static func replace(_ sysex: AnyMultiSysexible) -> (NuMultiSysexChange, AnyMultiSysexible?) {
    (.replace(sysex), sysex)
  }
}

//public enum TypedMultiSysexChange<Template:MultiSysexTemplate> {
//  case noop
//  case replace(FnMultiSysex<Template>)
//  case patch(SynthPath, PatchChange)
//  case bank(SynthPath, BankChange)
//}
