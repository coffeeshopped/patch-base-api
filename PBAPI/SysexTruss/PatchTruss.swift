
public protocol PatchTruss : SysexTruss {
  
  func parm(_ path: SynthPath) -> Parm?
  func paramKeys() -> [SynthPath]
  
  /// Break up a path into pieces to access patches at each level
  func subpaths(_ path: SynthPath) -> [SynthPath]?
  
  func randomize() -> SynthPathInts
    
  func getValue(_ bodyData: BodyData, path: SynthPath) -> Int?
  func setValue(_ bodyData: inout BodyData, path: SynthPath, _ value: Int)
  func allValues(_ bodyData: BodyData) -> SynthPathInts

  func getName(_ bodyData: BodyData) -> String?
  func setName(_ bodyData: inout BodyData, _ value: String)
  
  func getName(_ bodyData: BodyData, forPath path: SynthPath) -> String?
  func setName(_ bodyData: inout BodyData, forPath path: SynthPath, _ name: String)

  func allNames(_ bodyData: BodyData) -> [SynthPath:String]
}

public extension PatchTruss {

  /// Transform array of ParamOptions to dictionary. Later entries in the array with duplicate paths will overwrite earlier entries in the resulting dictionary.
  func paramsFromOpts(_ ins: [ParamOptions]) -> [SynthPath:Param] {
    var dict = [SynthPath:Param]()
    ins.forEach { po in
      dict[po.path] = po.param()
    }
    return dict
  }
  
}
