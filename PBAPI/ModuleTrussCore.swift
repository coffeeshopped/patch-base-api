
public struct ModuleTrussCore {
  
  public init(_ editorTruss: EditorTruss, manu: String, model: String, subid: String, sections: [ModuleTrussSection], pathFn: @escaping IndexPathFn, viewController: @escaping ViewControllerFn, filePath: @escaping FilePathFn, colorGuide: ColorGuide, indexPath: IndexPath? = nil, configPaths: [SynthPath]? = nil, postAddMsg: String? = nil) {
    self.editorTruss = editorTruss
    self.manufacturer = manu
    self.model = model
    self.id = "\(manu)\(model)"
    self.sections = sections
    self.path = pathFn
    self.viewController = viewController
    self.filePath = filePath
    self.colorGuide = colorGuide
    self.defaultIndexPath = indexPath ?? IndexPath(item: 1, section: 0)
    self.configPaths = configPaths ?? [[.global]]
    self.postAddMessage = postAddMsg
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
