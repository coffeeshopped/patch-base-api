import Foundation
import JavaScriptCore
import PBAPI

@objc protocol JsConsoleExport : JSExport {

  func log(_ data: Any)

}

public class JsConsole : NSObject, JsConsoleExport {

  public var logHandler: PBLogHandler?
  
  func log(_ data: Any) {
    if let logHandler = logHandler {
      logHandler.log(data)
    }
    else {
      debugPrint(data)
    }
  }

}
