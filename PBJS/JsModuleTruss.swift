
import PBAPI
import JavaScriptCore

public struct JsModuleTruss {
  
  public var console = JsConsole()
  public let package: JsPackage

  private var basicModuleTruss: BasicModuleTruss
  private let jsContext: JSContext
  private let require: @convention(block) (String, String) -> JSValue?

  init(packageDir: URL, package: JsPackage, localModuleURL: String) throws {
    self.package = package
    
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
        localBasePath = URL(fileURLWithPath: path).deletingLastPathComponent().path + "/"
//        localBasePath = "/"
      }
      else {
        expandedURL = packageDir.appendingPathComponent(localSubPath, isDirectory: true).appendingPathComponent(path, isDirectory: false)
        localBasePath = localSubPath + URL(fileURLWithPath: path).deletingLastPathComponent().path + "/"
      }
      
      // Return void or throw an error here.
      guard FileManager.default.fileExists(atPath: expandedURL.path)
          else { debugPrint("Require: filename \(expandedURL) does not exist")
                 return nil }

      guard let fileContent = try? String(contentsOfFile: expandedURL.path)
          else { return nil }
//      (function(exports, require, module, __filename, __dirname) {
//      // Module code actually lives in here
//      });

      jsContext.setObject(expandedURL, forKeyedSubscript: Self.currentPathKey)
      let wrapped = Self.wrapScript(localBasePath: localBasePath, fileContent: fileContent, currentPath: expandedURL.standardizedFileURL.path)
      return jsContext.evaluateScript(wrapped)
    }
    
    Self.register(jsContext, self.require, "SUPERrequire")
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

    guard let moduleScript = try? String(contentsOf: moduleURL) else {
      throw JSError.error(msg: "moduleScript missing: \(moduleURL)")
     }
    
//    let lbp = URL(fileURLWithPath: "\(packageName)/\(localModuleURL)").deletingLastPathComponent().path + "/"
    guard let moduleTemplate = jsContext.evaluateScript(Self.wrapScript(localBasePath: "" /*lbp*/, fileContent: moduleScript, currentPath: moduleURL.path), withSourceURL: moduleURL) else {
      throw JSError.error(msg: "createModule() failed")
    }
    // the exports of the eval'ed file should define a "module" property with the module truss
    
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
  
  private static func wrapScript(localBasePath: String, fileContent: String, currentPath: String) -> String {
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

  if (module.exports) {
    for (let key in module.exports) {
      try {
        Object.defineProperty(module.exports[key], "EXPORT_ORIGIN", {
          value: \"\(currentPath)\",
        });
      } catch(error) { }
    }
  }
  return module.exports;
})()
"""
  }
  
  private static func trussValue(truss: JSValue, bodyData: JSValue, path: JSValue) throws -> Int? {
    let t: any SysexTruss = try truss.xform(JsSysex.trussRules)
    let p: SynthPath = try path.x()
    
    switch t {
    case let single as SinglePatchTruss:
      return single.getValue(try bodyData.x(), path: p)
    default:
      throw JSError.error(msg: "Unknown truss type passed to trussValue.")
    }
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
