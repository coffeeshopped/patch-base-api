
public enum InfoSaveOption : Equatable {
  case noSave
  case usedPaths(bankPath: SynthPath, [[SynthPath]]) // bankPath, [[paths used]]
  case usedSlots(bankPath: SynthPath, [[MemSlot]]) // bankPath, [[paths used]]
}

public typealias InfoSaveItem = (title: String, srcPath: SynthPath, patch: AnySysexPatch, dest: MemSlot, saveOrder: Int, options: [InfoSaveOption])
