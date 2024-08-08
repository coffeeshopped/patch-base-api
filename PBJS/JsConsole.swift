import Foundation
import JavaScriptCore

@objc protocol JsConsoleExport : JSExport {

  func log(_ data: Any)

}

class JsConsole : NSObject, JsConsoleExport {

  func log(_ data: Any) {
    debugPrint(data)
  }

}
