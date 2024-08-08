
public struct BasicModuleTruss : ModuleTruss {  
  
  public var core: ModuleTrussCore

  public init(_ editorTruss: EditorTruss, manu: String, model: String, subid: String, sections: [ModuleTrussSection], pathFn: ModuleTrussCore.IndexPathFn? = nil, viewController: ModuleTrussCore.ViewControllerFn? = nil, dirMap: [SynthPath:String]? = nil, colorGuide: ColorGuide, indexPath: IndexPath? = nil, configPaths: [SynthPath]? = nil, postAddMsg: String? = nil) {
    
    let filePath: ModuleTrussCore.FilePathFn = {
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
    
    self.core = ModuleTrussCore(editorTruss, manu: manu, model: model, subid: subid, sections: sections, pathFn: path, viewController: viewController, filePath: filePath, colorGuide: colorGuide, indexPath: indexPath, configPaths: configPaths, postAddMsg: postAddMsg)
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
  
  

}
