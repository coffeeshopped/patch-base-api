
import JavaScriptCore
import PBAPI

#if os(macOS)
let JS_BASE_PATH = "/Users/chadwickwood/Code/synth-editors/"
#else
let JS_BASE_PATH = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].path + "/Code/"
#endif

/// On creation, loads the basic info about a Synth Module. Can generate a ModuleTruss.
public struct JsModuleWerk: ModuleProvider {
  
  public var postAddMessage: String? = nil // TODO
  
  public var productId: String { "\(manufacturer).\(model)" }
  
  public func moduleTruss() throws -> JsModuleTruss {
    try JsModuleTruss(packageDir: packageDir, packageName: packageName, localModuleURL: localModuleURL)
  }
  
  public let id: String
  public let manufacturer: String
  public let model: String
  public let localModuleURL: String

  private let packageDir: URL
  private let packageName: String
    
  static func setException(_ value: JSValue, _ str: String) {
    value.context.exception = .init(object: str, in: value.context)
  }

  
  public init(packageDir: URL, packageName: String, dict: [String:String]) throws {
    self.packageDir = packageDir
    self.packageName = packageName

    guard let name = dict["name"] else {
      throw JSError.error(msg: "name missing")
    }
    self.id = "\(packageName)/\(name)"

    guard let manu = dict["manufacturer"] else {
      throw JSError.error(msg: "manufacturer missing")
    }
    self.manufacturer = manu

    guard let model = dict["model"] else {
      throw JSError.error(msg: "model missing")
     }
    self.model = model
        
    guard let moduleURL = dict["module"] else {
      throw JSError.error(msg: "module path missing")
    }
    self.localModuleURL = moduleURL
  }
      
}

