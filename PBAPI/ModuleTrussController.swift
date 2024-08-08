
public enum ModuleTrussController {
  case custom(PatchController)
  case voice(PatchController)
  case perf(PatchController)
  case bank
  case fullRef
  case backup
  
  public var hasKeyboard: Bool {
    switch self {
    case .voice, .perf:
      return true
    default:
      return false
    }
  }
}
