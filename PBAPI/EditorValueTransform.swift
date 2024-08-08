
public enum EditorValueTransform: Hashable {
  
  case value(_ editorPath: SynthPath, _ paramPath: SynthPath, defaultValue: Int = 0)
  case basicChannel
  case constant(_ value: Int)
  case patch(_ editorPath: SynthPath)
  case extra(_ patchPath: SynthPath, _ paramPath: SynthPath)
  
}
