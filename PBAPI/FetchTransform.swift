
public indirect enum FetchTransform {
  
  /// Generate commands based on the truss at the editor's path
  case truss(_ fn: (_ editor: AnySynthEditor) throws -> [UInt8])
  case bankTruss(_ fn: (_ editor: AnySynthEditor, _ location: UInt8) throws -> [UInt8], waitInterval: Int = 0)
  case sequence([FetchTransform])
  case custom(_ fn: (_ editor: AnySynthEditor) throws -> [RxMidi.FetchCommand]?)
  
}
