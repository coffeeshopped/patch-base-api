
import JavaScriptCore
import PBAPI

#if os(macOS)
let JS_BASE_PATH = "/Users/chadwickwood/Code/synth-editors/"
#else
let JS_BASE_PATH = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].path + "/Code/"
#endif

/// On creation, loads the basic info about a Synth Module. Can generate a ModuleTruss.
public struct JsModuleProvider: ModuleProvider {
  
  public var postAddMessage: String? = nil // TODO
  
  public var productId: String { "\(manufacturer).\(model)" }
  
  public func moduleTruss() throws -> JsModuleTruss {
    try JsModuleTruss(packageDir: packageDir, package: package, localModuleURL: localModuleURL, debugMode: true)
  }
  
  public let manufacturer: String
  public let model: String
  public let localModuleURL: String

  private let packageDir: URL
  public let package: JsPackage
    
  static func setException(_ value: JSValue, _ str: String) {
    value.context.exception = .init(object: str, in: value.context)
  }

  
  public init(packageDir: URL, package: JsPackage, dict: [String:String]) throws {
    self.packageDir = packageDir
    self.package = package

    guard let name = dict["name"] else {
      throw JSError.error(msg: "name missing")
    }

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

