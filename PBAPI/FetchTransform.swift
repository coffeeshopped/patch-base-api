
public indirect enum FetchTransform {
  
  /// Generate commands based on the truss at the editor's path
  case truss(_ fn: SinglePatchTruss.Core.ToMidiFn)
  // bodyData passed to bankTruss fn should be an array with a single byte representing the fetch location
  case bankTruss(_ fn: SinglePatchTruss.Core.ToMidiFn, bytesPerPatch: Int? = nil, waitInterval: Int = 0)
  case sequence([FetchTransform])
  case custom(_ fn: (_ editor: AnySynthEditor) throws -> [RxMidi.FetchCommand]?)
  
}
