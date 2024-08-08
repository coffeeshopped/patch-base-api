
public protocol AnySynthModule {
  
  var anySynthEditor: AnySynthEditor! { get }

  func synthPath(forIndexPath: IndexPath) -> SynthPath?
  func indexPath(forSynthPath synthPath: SynthPath) -> IndexPath?
//  func viewController(forIndexPath: IndexPath) -> PBController

//  func connect(viewController: PBController, synthPath: SynthPath)
//  func basicSynthSaveController() -> PBController

  func synthSaveInfoItems(path: SynthPath) -> [NuInfoSaveItem]
  func defaultInfoItems(path: SynthPath) throws -> [NuInfoSaveItem]

}
