
public struct ParamHelper {
    
  public static func noteName(_ noteNumber: Int) -> String {
    let notes = ["C","C#","D","D#","E","F","F#","G","G#","A","A#","B"]
    let oct = noteNumber/12 - 1
    let note = notes[noteNumber % 12]
    return "\(note)\(oct)"
  }
  
  public static let noteNameFormatter: ParamValueFormatter = {
    return noteName($0)
  }

}
