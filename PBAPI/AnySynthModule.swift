
public protocol AnySynthModule {
  
  var anySynthEditor: AnySynthEditor! { get }

  func synthPath(forIndexPath: IndexPath) -> SynthPath?
  func indexPath(forSynthPath synthPath: SynthPath) -> IndexPath?

  func defaultInfoItems(path: SynthPath) throws -> [InfoSaveItem]

}
