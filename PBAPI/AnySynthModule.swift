
public protocol AnySynthModule {
  
  var anySynthEditor: AnySynthEditor! { get }

  func synthPath(forIndexPath: IndexPath) -> SynthPath?
  func indexPath(forSynthPath synthPath: SynthPath) -> IndexPath?

  func synthSaveInfoItems(path: SynthPath) -> [InfoSaveItem]
  func defaultInfoItems(path: SynthPath) throws -> [InfoSaveItem]

}
