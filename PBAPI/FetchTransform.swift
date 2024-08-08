
public indirect enum FetchTransform {
  
  /// Generate commands based on the truss at the editor's path
  case truss(_ valueTransform: EditorValueTransform?, _ fn: (_ value: Int) throws -> [UInt8])
  case bankTruss(_ valueTransform: EditorValueTransform?, _ fn: (_ value: Int, _ location: Int) throws -> [UInt8], waitInterval: Int = 0)
  case sequence([FetchTransform])
  case custom(_ valueTransforms: [EditorValueTransform], _ fn: (_ values: [EditorValueTransform:Any], _ path: SynthPath) throws -> [RxMidi.FetchCommand]?)
  
}
