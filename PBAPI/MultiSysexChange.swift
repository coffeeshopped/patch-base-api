
public indirect enum MultiSysexChange : Change {
  public typealias Sysex = AnyMultiSysexible
  
  case noop
  case replace(AnyMultiSysexible)
  case patch(SynthPath, PatchChange)
  case bank(SynthPath, BankChange)
  case patchSwap(SynthPath, SynthPath) // across banks! last item is i(index)
  case nameChange(String)
  case push
  
  public static func replace(_ sysex: AnyMultiSysexible) -> (MultiSysexChange, AnyMultiSysexible?) {
    (.replace(sysex), sysex)
  }
}
