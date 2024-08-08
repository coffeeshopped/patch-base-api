
public struct BasicEditorTruss : EditorTruss {

  public var core: EditorTrussCore
  
  public init(_ displayId: String, truss: [(SynthPath, any SysexTruss)]) {
    self.core = EditorTrussCore(displayId, truss: truss)
  }
  
}
