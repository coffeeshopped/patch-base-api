
public enum NuBankChange : Change {
  public typealias Sysex = AnySysexPatchBank
  
  case replace(AnySysexPatchBank)
  case patchChange([Int:AnySysexPatch])
  case patchSwap(Int,Int)
  case nameChange(String)
  case push
 
  public static func replace(_ sysex: AnySysexPatchBank) -> (NuBankChange, AnySysexPatchBank?) {
    (.replace(sysex), sysex)
  }
}
