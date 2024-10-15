
public enum MidiChannelTransform {
  public typealias MapFn = ((Int) throws -> Int)
  
  case basic(map: MapFn? = nil)
  case patch(_ editorPath: SynthPath, _ paramPath: SynthPath, map: MapFn? = nil)
  case custom(_ transforms: [EditorValueTransform], _ fn: (_ value: [EditorValueTransform:Int]) -> Int)
  
}
