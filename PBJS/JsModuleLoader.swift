
import PBAPI

struct JsPackage: Codable {
  var name: String
  var version: String
  var description: String
  var modules: [[String:String]]
}

public struct JsModuleLoader {
  
  public static func loadModules(dirs: [String]) throws -> [JsModuleWerk] {
    var werks = [JsModuleWerk]()
    
    let decoder = JSONDecoder()
    try dirs.forEach { dir in
      let packageBasePath = "\(JS_BASE_PATH)\(dir)/"

      let data = try Data(contentsOf: URL(fileURLWithPath: "\(packageBasePath)package.json"))
      let package = try decoder.decode(JsPackage.self, from: data)
      try package.modules.forEach { modDict in
        do {
          werks.append(try JsModuleWerk(packageName: dir, dict: modDict))
        }
        catch {
          throw JSError.wrap("JS Module load error. Package: \(dir)\nDictionary: \(modDict.debugDescription)", error)
        }
      }
    }
    return werks
  }
  
}
