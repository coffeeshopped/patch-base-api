
public enum ModuleCommand {
  
  // mark (controller) window as needing to be re-created (including associated controller)
  case invalidateWindow(SynthPath)
  
}
