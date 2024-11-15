
import JavaScriptCore
import PBAPI

#if os(macOS)
let JS_BASE_PATH = "/Users/chadwickwood/Code/patch-base-editors/"
#else
let JS_BASE_PATH = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].path + "/Code/"
#endif

/// On creation, loads the basic info about a Synth Module. On first access of moduleTruss, the moduleTruss is parsed from JS and cached.
public struct JsModuleWerk: ModuleProvider {
  
  public var postAddMessage: String? = nil // TODO
  
  public var productId: String { "\(manufacturer).\(model)" }

//  private var _moduleTruss: BasicModuleTruss? = nil
  
  public mutating func moduleTruss() throws -> BasicModuleTruss {
//    if let t = _moduleTruss { return t }
    return try loadModuleTruss()
  }
  
  private var jsContext: JSContext? = nil
  private var require: (@convention(block) (String, String) -> JSValue?)? = nil
  
  public let id: String
  public let manufacturer: String
  public let model: String
  public let moduleURL: URL
  public let localModuleURL: String
  public let moduleBasePath: String

  private let packageName: String
  public var console = JsConsole()
  
  private static let moduleBasePathKey: NSString = "MODULE_PATH"
  static func moduleBasePath(_ value: JSValue) throws -> String {
    try value.context.objectForKeyedSubscript(moduleBasePathKey).x()
  }
  
  private static let currentPathKey: NSString = "CURRENT_PATH"
  static func currentPath(_ value: JSValue) throws -> String {
    try value.context.objectForKeyedSubscript(currentPathKey).x()
  }
  
  static func setException(_ value: JSValue, _ str: String) {
    value.context.exception = .init(object: str, in: value.context)
  }

  
  init(packageName: String, dict: [String:String]) throws {
    self.packageName = packageName
    self.moduleBasePath = "\(JS_BASE_PATH)\(packageName)/"

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
    
    self.moduleURL = URL(fileURLWithPath: "\(moduleBasePath)\(moduleURL)")

  }
  
  
  private mutating func loadModuleTruss() throws -> BasicModuleTruss {
    guard let jsContext = JSContext() else {
      throw JSError.error(msg: "JSContext couldn't be created")
     }
    self.jsContext = jsContext
    
    require = { [unowned jsContext] path, localSubPath in
      let expandedPath: String
      let localBasePath: String
      if path.starts(with: "/") {
        expandedPath = "\(JS_BASE_PATH)\(path)"
        localBasePath = URL(fileURLWithPath: path).deletingLastPathComponent().path + "/"
//        localBasePath = "/"
      }
      else {
        expandedPath = "\(JS_BASE_PATH)\(localSubPath)\(path)"
        localBasePath = localSubPath + URL(fileURLWithPath: path).deletingLastPathComponent().path + "/"
      }
      
      // Return void or throw an error here.
      guard FileManager.default.fileExists(atPath: expandedPath)
          else { debugPrint("Require: filename \(expandedPath) does not exist")
                 return nil }

      guard let fileContent = try? String(contentsOfFile: expandedPath)
          else { return nil }

//      (function(exports, require, module, __filename, __dirname) {
//      // Module code actually lives in here
//      });

      jsContext.setObject(expandedPath, forKeyedSubscript: Self.currentPathKey)
      let wrapped = Self.wrapScript(localBasePath: localBasePath, fileContent: fileContent)
      return jsContext.evaluateScript(wrapped)
    }

    Self.register(jsContext, self.require!, "SUPERrequire")
    Self.register(jsContext, self.console, "console")
    Self.register(jsContext, JsSynthPath.pathEq, "pathEq")
    Self.register(jsContext, JsSynthPath.pathLen, "pathLen")
    Self.register(jsContext, JsSynthPath.pathPart, "pathPart")

    Self.registerWrapped3(jsContext, "trussValue", Self.trussValue)

    jsContext.exceptionHandler = { context, exception in
      context?.exception = exception
    }
    jsContext.setObject(moduleBasePath, forKeyedSubscript: Self.moduleBasePathKey)
    jsContext.setObject(moduleURL, forKeyedSubscript: Self.currentPathKey)
    
    guard let moduleScript = try? String(contentsOf: self.moduleURL) else {
      throw JSError.error(msg: "moduleScript missing")
     }
    
    let lbp = URL(fileURLWithPath: "\(packageName)/\(localModuleURL)").deletingLastPathComponent().path + "/"
    guard let moduleTemplate = jsContext.evaluateScript(Self.wrapScript(localBasePath: lbp, fileContent: moduleScript), withSourceURL: self.moduleURL) else {
      throw JSError.error(msg: "createModule() failed")
    }
    // the exports of the eval'ed file should define a "module" property with the module truss
//    _moduleTruss = try moduleTemplate.x("module")
    return try moduleTemplate.x("module")
  }
  
  
  
  static func trussValue(truss: JSValue, bodyData: JSValue, path: JSValue) throws -> Int? {
    let t: any SysexTruss = try truss.xform(JsSysex.trussRules)
    let p: SynthPath = try path.x()
    
    switch t {
    case let single as SinglePatchTruss:
      return single.getValue(try bodyData.x(), path: p)
    default:
      throw JSError.error(msg: "Unknown truss type passed to trussValue.")
    }
  }

  private static func registerWrapped2(_ jsContext: JSContext, _ key: String, _ fn: @escaping (JSValue, JSValue) throws -> Any?) {
    let x: @convention(block) (JSValue, JSValue) -> JSValue? = { [unowned jsContext] in
      callWrapped(jsContext, args: $0, $1, fn: fn)
    }
    register(jsContext, x, key)
  }
  
  private static func registerWrapped3(_ jsContext: JSContext, _ key: String, _ fn: @escaping (JSValue, JSValue, JSValue) throws -> Any?) {
    let x: @convention(block) (JSValue, JSValue, JSValue) -> JSValue? = { [unowned jsContext] in
      callWrapped(jsContext, args: $0, $1, $2, fn: fn)
    }
    register(jsContext, x, key)
  }
  
  private static func callWrapped<each V: JSValue>(_ jsContext: JSContext, args: repeat each V, fn: (repeat each V) throws -> Any?) -> JSValue? {
    do {
      guard let v = try fn(repeat each args) else { return nil }
      switch v {
      case let i as Int:
        return JSValue(int32: Int32(i), in: jsContext)
      default:
        throw JSError.error(msg: "Unknown function return type: \(v)")
      }
    }
    catch {
      switch error {
      case let err as JSError:
        jsContext.exception = JSValue(object: err.display(), in: jsContext)
      default:
        jsContext.exception = JSValue(object: error.localizedDescription, in: jsContext)
      }
    }
    return nil
  }
  
  private static func register(_ jsContext: JSContext, _ object: Any, _ key: String) {
    jsContext.setObject(object, forKeyedSubscript: key as NSString)
  }
  
  private static func wrapScript(localBasePath: String, fileContent: String) -> String {
    "(function() { const module = { exports: {} }; function req(module, exports) { function require(path) { return SUPERrequire(path, \"\(localBasePath)\"); }; \(fileContent) \n }; req(module, module.exports); return module.exports; })()"
  }
      
}

