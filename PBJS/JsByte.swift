
//import JavaScriptCore
//
//@objc protocol JsByteExport : JSExport {
//
//  static func pack78(_ bytes: [UInt8], _ outCount: Int) -> [UInt8]
//  static func unpack87(_ bytes: [UInt8], _ outCount: Int, _ from: Int, _ upTo: Int) -> [UInt8]
//
//}
//
//class JsByte : NSObject, JsByteExport {
//  
//  class func pack78(_ bytes: [UInt8], _ outCount: Int) -> [UInt8] {
//    bytes.pack78(count: outCount)
//  }
//  
//  class func unpack87(_ bytes: [UInt8], _ outCount: Int, _ from: Int, _ upTo: Int) -> [UInt8] {
//    Data(bytes).unpack87(count: outCount, inRange: from..<upTo)
//  }
//
//}
