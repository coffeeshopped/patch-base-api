import PBAPI

extension PatchChange : JsPassable {
  
  func toJS() -> AnyHashable {
    switch self {
    case .nameChange(let path, let name):
      return [
        "nameChange" : path.toJS(),
        "name" : name,
      ]
    case .paramsChange(let values):
      return values.toJS()
    case .replace(let patch):
      guard let values = try? patch.allValues() else {
        return [:] as [String:Int]
      }
      return values.toJS()
    case .noop, .push:
      return [:] as [String:Int]
    }
  }
  
  
}
