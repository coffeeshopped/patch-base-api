
public enum EditorPathTransform {
  
  case patchParam(_ editorPath: SynthPath, _ paramPath: SynthPath, _ fn: (Int) -> SynthPath?)
  
}
