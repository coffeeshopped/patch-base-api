import OrderedCollections

public struct EditorTruss {
  
  public let displayId: String

  // Q: Why both of these?
  // A: sysexMap is more "raw". Used by the backing document to create all possible Sysexibles used
  public let sysexMap : [SynthPath:any SysexTruss]
  
  // sysexibles that are really just clusters of other existing sysexibles (e.g. backups)
  public let compositeMap: [SynthPath:any MultiSysexTruss]
  
  public init(_ displayId: String, truss: [(SynthPath, any SysexTruss)]) {
    self.displayId = displayId
    self.sysexMap = truss.filter({ !($1 is any MultiSysexTruss) }).dict { [$0.0 : $0.1] }
    self.compositeMap = truss.compactDict {
      guard let mst = $0.1 as? any MultiSysexTruss else { return nil }
      return [$0.0 : mst]
    }
    self.paths = Array(sysexMap.keys)
  }
  
  public let paths: [SynthPath]
    
  // path : ms
  public var compositeSendWaitInterval: Int = 0
  public var compositeFetchWaitInterval: Int = 0 // msec to wait between fetches of composite parts

  
  public var fetchTransforms: [SynthPath:FetchTransform] = [:]

  public var midiOuts: [(path: SynthPath, transform: MidiTransform)] = []
    
  public var midiChannels: [SynthPath:MidiChannelTransform] = [:]

  public var extraParamOuts: [SynthPath:ParamOutTransform] = [:]
    
  public var slotTransforms: [SynthPath:MemSlot.Transform] = [:]
  
  public var commandEffects: [EditorCommandEffect] = []

  public var pathTransforms: [SynthPath:EditorPathTransform] = [:]

  public typealias ExtraValues = [SynthPath:[SynthPath:Int]]
  /// Non-patch-byte based values that need to be stored in the editor. E.g. Op off/on values for older FM synths that don't actually store that info in the patch itself. [<editor path> : [<param path>]]. Stores ints only.
  public var extraValues: ExtraValues = [:]
}

public extension EditorTruss {
  
  /// All of the FullRefTrusses used by this editor
  var refTrusses: [FullRefTruss] {
    compositeMap.compactMap { $0.value as? FullRefTruss }
  }
    
  /// Return a FullRefTruss that uses the passed PatchTruss as its refTruss (if exists)
  func refTruss(basedOn: any PatchTruss) -> FullRefTruss? {
    refTrusses.filter({ $0.refTruss.displayId == basedOn.displayId }).first
  }

}
