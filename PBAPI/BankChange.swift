
public enum BankChange : Change {
  
  case replace(AnySysexPatchBank)
  case patchChange([Int:AnySysexPatch])
  case patchSwap(Int,Int)
  case nameChange(String)
  case push
 
  public static func replace(_ sysex: AnySysexPatchBank) -> (Self, AnySysexPatchBank?) {
    (.replace(sysex), sysex)
  }

  public static var none: Self { .patchChange([:]) }

}
