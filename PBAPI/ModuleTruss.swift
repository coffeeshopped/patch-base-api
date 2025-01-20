
public protocol ModuleTruss : ModuleProvider {
  
  var core: ModuleTrussCore { get set }
  
  var editorTruss: EditorTruss { get }
  
  var id: String { get }
  var manufacturer: String { get }
  var model: String { get }
//  var imageURL: URL { get }
//  var moduleURL: URL { get }
    
  var localPath: String { get }

//  var baseURL: URL! { get }

  var colorGuide: ColorGuide { get }

  var sections: [ModuleTrussSection] { get }

  var defaultIndexPath: IndexPath { get }
  
  // synth editor paths that should always be unlocked and not have init/random features (e.g. Global editors)
  var configPaths: [SynthPath] { get }
    
  func path(forIndexPath indexPath: IndexPath) -> SynthPath?
  
  func bankInfo(forPatchTruss patchTruss: any PatchTruss) -> [(SynthPath, String)]
  
//  func synthSaveInfoItems(_ module: SynthModule, path: SynthPath) -> [InfoSaveItem]
  
//  func onEditorLoad(_ module: SynthModule)

}

public extension ModuleTruss {
  
  var editorTruss : EditorTruss { core.editorTruss }
  var id: String { core.id }
  var manufacturer: String { core.manufacturer }
  var model: String { core.model }
  
  var colorGuide: ColorGuide {
    get { core.colorGuide }
  }

  var sections: [ModuleTrussSection] { core.sections }

  var defaultIndexPath: IndexPath {
    get { core.defaultIndexPath }
  }

  var configPaths: [SynthPath] {
    get { core.configPaths }
  }

  var postAddMessage: String? {
    get { core.postAddMessage }
  }

  var filePath: ModuleTrussCore.FilePathFn {
    get { core.filePath }
  }

  var path: (_ indexPath: IndexPath) -> SynthPath? {
    get { core.path }
  }

  var viewController: ModuleTrussCore.ViewControllerFn {
    get { core.viewController }
  }

//  var saveToSynthController: (_ module: AnySynthModule, _ indexPath: IndexPath) -> PBController? {
//    get { core.saveToSynthController }
//    set { core.saveToSynthController = newValue }
//  }

  var synthSaveInfoItems: (_ module: AnySynthModule, _ path: SynthPath) -> [InfoSaveItem] {
    get { core.synthSaveInfoItems }
    set { core.synthSaveInfoItems = newValue }
  }

  var onEditorLoad: (_ module: AnySynthModule) -> Void {
    get { core.onEditorLoad }
    set { core.onEditorLoad = newValue }
  }

}

public extension ModuleTruss {

  func path(forIndexPath indexPath: IndexPath) -> SynthPath? {
    self.path(indexPath)
  }
        
}

public extension ModuleTruss {
  
  var productId: String { id }
  
  var localPath: String {
    // replace any slashes with dashes (e.g. Proteus/2"
    let moduleComponent = "\(manufacturer) \(model)".replacingOccurrences(of: "/", with: "-")
    return URL(string: "Modules")!.appendingPathComponent(moduleComponent).path
  }

  var defaultPatchDirectory: String { "Patches" }
  
  func title(forPath path: SynthPath) -> String? {
    sections.compactMap { $0.items.first { $0.path == path }?.title }.first
  }

  var commandEffects: [ModuleCommandEffect] {
    get { core.commandEffects }
    set { core.commandEffects = newValue }
  }
  


}
