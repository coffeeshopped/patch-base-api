
import PBAPI
import JavaScriptCore

public struct JsModuleTruss {
  
  public var console = JsConsole()
  public let package: JsPackage

  private var basicModuleTruss: BasicModuleTruss
  private let jsContext: JSContext
  private let require: @convention(block) (String, String) -> JSValue?
  
  private let debugMode: Bool

  init(packageDir: URL, package: JsPackage, localModuleURL: String, debugMode: Bool) throws {
    self.package = package
    self.debugMode = debugMode
    
    let moduleBaseURL = packageDir
    let moduleBasePath = moduleBaseURL.path
    let moduleURL = moduleBaseURL.appendingPathComponent(localModuleURL)

    guard let jsContext = JSContext() else {
      throw JSError.error(msg: "JSContext couldn't be created")
     }
    self.jsContext = jsContext
    
    self.require = { [unowned jsContext] path, localSubPath in
      let expandedURL: URL
      let localBasePath: String
      if path.starts(with: "/") {
        expandedURL = packageDir.appendingPathComponent(path, isDirectory: false)
        localBasePath = URL(string: path)!.deletingLastPathComponent().path + "/"
//        localBasePath = "/"
      }
      else {
        expandedURL = packageDir.appendingPathComponent(localSubPath, isDirectory: true).appendingPathComponent(path, isDirectory: false)
        localBasePath = localSubPath + URL(string: path)!.deletingLastPathComponent().path + "/"
      }
      
      // Return void or throw an error here.
      guard FileManager.default.fileExists(atPath: expandedURL.path),
            let fileContent = try? String(contentsOfFile: expandedURL.path) else {
        jsContext.exception = JSValue(newErrorFromMessage: "File for require() does not exist: \(expandedURL.path)\n\n\(path)\n\n\(expandedURL.path)", in: jsContext)
        return nil
      }

//      (function(exports, require, module, __filename, __dirname) {
//      // Module code actually lives in here
//      });

      jsContext.setObject(expandedURL, forKeyedSubscript: Self.currentPathKey)
      let wrapped = Self.wrapScript(localBasePath: localBasePath, fileContent: fileContent, currentPath: expandedURL.standardizedFileURL.path, debugMode: debugMode)
      return jsContext.evaluateScript(wrapped)
    }
    
    Self.register(jsContext, self.require, "SUPERrequire")
    Self.register(jsContext, self.console, "console")
    Self.register(jsContext, JsSynthPath.pathEq, "pathEq")
    Self.register(jsContext, JsSynthPath.pathLen, "pathLen")
    Self.register(jsContext, JsSynthPath.pathPart, "pathPart")
    Self.register(jsContext, JsSynthPath.pathLast, "pathLast")

    jsContext.exceptionHandler = { context, exception in
      context?.exception = exception
    }
    jsContext.setObject(moduleBasePath, forKeyedSubscript: Self.moduleBasePathKey)
    jsContext.setObject(moduleURL, forKeyedSubscript: Self.currentPathKey)

    guard let moduleScript = try? String(contentsOf: moduleURL) else {
      throw JSError.error(msg: "moduleScript missing: \(moduleURL)")
     }
    
//    let lbp = URL(fileURLWithPath: "\(packageName)/\(localModuleURL)").deletingLastPathComponent().path + "/"
    guard let moduleTemplate = jsContext.evaluateScript(Self.wrapScript(localBasePath: "" /*lbp*/, fileContent: moduleScript, currentPath: moduleURL.path, debugMode: debugMode), withSourceURL: moduleURL) else {
      throw JSError.error(msg: "createModule() failed")
    }
    // the exports of the eval'ed file should define a "module" property with the module truss
    
    if let exception = jsContext.exception {
      throw JSError.error(msg: exception.debugDescription)
    }
    
    self.basicModuleTruss = try moduleTemplate.x("module")
  }
  
  private static let moduleBasePathKey: NSString = "MODULE_PATH"
  static func moduleBasePath(_ value: JSValue) throws -> String {
    try value.context.objectForKeyedSubscript(moduleBasePathKey).x()
  }
  
  private static let currentPathKey: NSString = "CURRENT_PATH"
  static func currentPath(_ value: JSValue) throws -> String {
    try value.context.objectForKeyedSubscript(currentPathKey).x()
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
      jsContext.exception = JSValue(object: error.localizedDescription, in: jsContext)
    }
    return nil
  }
  
  private static func register(_ jsContext: JSContext, _ object: Any, _ key: String) {
    jsContext.setObject(object, forKeyedSubscript: key as NSString)
  }
  
  private static func wrapScript(localBasePath: String, fileContent: String, currentPath: String, debugMode: Bool) -> String {
    """
(function() { 
  const module = { exports: {} };
  function req(module, exports) {
    function require(path) {
      return SUPERrequire(path, \"\(localBasePath)\");
    }; 
    \(fileContent)
  };
  req(module, module.exports);

  function setExportOrigin(obj) {
    for (let key in obj) {
      try {
        Object.defineProperty(obj[key], "EXPORT_ORIGIN", {
          value: \"\(currentPath)\",
        });
        setExportOrigin(obj[key])
      } catch(error) { }
    }
  }

  if (\(debugMode ? "true" : "false") && module.exports) {
    setExportOrigin(module.exports)
  }
  return module.exports;
})()
"""
  }

}

extension JsModuleTruss : ModuleTruss {
  
  public var core: PBAPI.ModuleTrussCore {
    get {
      basicModuleTruss.core
    }
    set(newValue) {
      basicModuleTruss.core = newValue
    }
  }
  
  public func bankInfo(forPatchTruss patchTruss: any PBAPI.PatchTruss) -> [(PBAPI.SynthPath, String)] {
    basicModuleTruss.bankInfo(forPatchTruss: patchTruss)
  }

}
