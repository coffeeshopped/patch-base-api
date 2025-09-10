
public struct ModuleTruss {

  // TODO: subid is not used. Should it be?
  public init(_ editorTruss: EditorTruss, manu: String, model: String, subid: String, sections: [ModuleTrussSection], pathFn: IndexPathFn? = nil, viewController: ViewControllerFn? = nil, dirMap: [SynthPath:String]? = nil, colorGuide: ColorGuide, indexPath: IndexPath? = nil, configPaths: [SynthPath]? = nil, postAddMsg: String? = nil) {
    
    let filePath: FilePathFn = {
      let path = $0.anySynthEditor.map(fromPath: $1)
      return path?.directory({ dirMap?[$0] })
    }

    let path = pathFn ?? { indexPath in
      guard indexPath.section < sections.count && indexPath.item < sections[indexPath.section].items.count else { return nil }
      return sections[indexPath.section].items[indexPath.item].path
    }
    
    let viewController = viewController ?? { module, indexPath in
      sections[indexPath.section].items[indexPath.item].controller
    }
    
    self.editorTruss = editorTruss
    self.id = "\(manu)\(model)"

    self.manufacturer = manu
    self.model = model
    self.sections = sections
    self.path = path
    self.viewController = viewController
    self.filePath = filePath
    self.colorGuide = colorGuide
    self.defaultIndexPath = indexPath ?? IndexPath(item: 1, section: 0)
    self.configPaths = configPaths ?? [[.global]]
    self.postAddMessage = postAddMsg
  }
  
  public func bankInfo(forPatchTruss patchTruss: any PatchTruss) -> [(SynthPath, String)] {
    // find the editor paths that map to banks of this patch truss
    let paths = editorTruss.sysexMap.filter {
      guard let bankTruss = $0.value as? (any BankTruss) else { return false }
      return bankTruss.anyPatchTruss.displayId == patchTruss.displayId
    }.map { $0.key }
    
    // find the section titles in the module that use that path
    return sections.flatMap {
      $0.items.filter({ paths.contains($0.path) }).map { ($0.path, $0.title) }
    }
  }
  
  
  public let editorTruss: EditorTruss
  public let id: String
  public let manufacturer: String
  public let model: String
  public let sections: [ModuleTrussSection]
  public typealias IndexPathFn = (_ indexPath: IndexPath) -> SynthPath?
  public let path: IndexPathFn
  public typealias ViewControllerFn = (_ module: AnySynthModule, _ indexPath: IndexPath) -> ModuleTrussController
  public let viewController: ViewControllerFn
  public typealias FilePathFn = (_ module: AnySynthModule, _ synthPath: SynthPath) -> String?
  public let filePath: FilePathFn
  
  public let colorGuide: ColorGuide
  public let defaultIndexPath: IndexPath
  public let configPaths: [SynthPath]
  public let postAddMessage: String?

  public var commandEffects: [ModuleCommandEffect] = []
    
  public var synthSaveInfoItems: (_ module: AnySynthModule, _ path: SynthPath) -> [InfoSaveItem] = { module, path in (try? module.defaultInfoItems(path: path)) ?? [] }

  public var onEditorLoad: (_ module: AnySynthModule) -> Void = { _ in }
  

}

public extension ModuleTruss {
  
//  var saveToSynthController: (_ module: AnySynthModule, _ indexPath: IndexPath) -> PBController? {
//    get { core.saveToSynthController }
//    set { core.saveToSynthController = newValue }
//  }

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


}
