
public protocol EditorTruss {
  
  var core: EditorTrussCore { get set }
    
}


public extension EditorTruss {
  
  var displayId: String { core.displayId }

  var sysexMap : [SynthPath:any SysexTruss] { core.sysexMap }
  
  var paths : [SynthPath] { core.paths }
  
  var compositeMap: [SynthPath:any MultiSysexTruss] { core.compositeMap }
      
  var compositeSendWaitInterval: Int {
    get { core.compositeSendWaitInterval }
    set { core.compositeSendWaitInterval = newValue }
  }
  
  var compositeFetchWaitInterval: Int {
    get { core.compositeFetchWaitInterval }
    set { core.compositeFetchWaitInterval = newValue }
  }
  
  var fetchTransforms: [SynthPath:FetchTransform] {
    get { core.fetchTransforms }
    set { core.fetchTransforms = newValue }
  }

  var midiOuts: [(path: SynthPath, transform: MidiTransform)] {
    get { core.midiOuts }
    set { core.midiOuts = newValue }
  }
    
  var midiChannels: [SynthPath:MidiChannelTransform] {
    get { core.midiChannels }
    set { core.midiChannels = newValue }
  }

  var extraParamOuts: [(path: SynthPath, transform: ParamOutTransform)] {
    get { core.extraParamsOuts }
    set { core.extraParamsOuts = newValue }
  }
  
  var slotTransforms: [SynthPath:MemSlot.Transform] {
    get { core.slotTransforms }
    set { core.slotTransforms = newValue }
  }

  var commandEffects: [EditorCommandEffect] {
    get { core.commandEffects }
    set { core.commandEffects = newValue }
  }
  
  var extraValues: [SynthPath:[SynthPath:Int]] {
    get { core.extraValues }
    set { core.extraValues = newValue }
  }

  
  // allows the FnStateDocument itself to handle internal remapping (e.g. XV series) based on this Template plus the doc's internal state
  var pathTransforms: [SynthPath:EditorPathTransform] {
    get { core.pathTransforms }
    set { core.pathTransforms = newValue }
  }
  

}

public extension EditorTruss {
  
  /// All of the FullRefTrusses used by this editor
  var refTrusses: [FullRefTruss] {
    sysexMap.compactMap { $0.value as? FullRefTruss }
  }
    
  /// Return a FullRefTruss that uses the passed PatchTruss as its refTruss (if exists)
  func refTruss(basedOn: any PatchTruss) -> FullRefTruss? {
    refTrusses.filter({ $0.refTruss.displayId == basedOn.displayId }).first
  }

}
