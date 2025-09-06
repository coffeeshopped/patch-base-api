//
//  JsParsable.swift
//  PBJS
//
//  Created by Chadwick Wood on 9/6/25.
//

import JavaScriptCore
import PBAPI

public protocol JsParsable {
  
  static var jsRules: [JsParseRule<Self>] { get }
  static var jsArrayRules: [JsParseRule<[Self]>] { get }
  
  static func matches(_ x: JSValue) -> Bool
  
  static func jsName() -> String
}

extension JsParsable {
  public static func matches(_ x: JSValue) -> Bool {
    !x.isNull && !x.isUndefined
  }
  
  public static func jsName() -> String {
    String(reflecting: self).replacingOccurrences(of: "PBAPI.", with: "").replacingOccurrences(of: "Swift.", with: "")
  }
}

//extension JsParsable {
//  static func x(_ v: JSValue) throws -> Self {
//    try v.xform(jsParsers)
//  }
//}

extension JsParsable {
  
  public static var jsArrayRules: [JsParseRule<[Self]>] { [] }
  
  static func defaultArrayRule() -> JsParseRule<[Self]> {
    .t([Self].self, {
      // ok, so what are we doing here?
      guard $0.arrCount() > 0 else { return [] }
      // go through each item
      return try $0.flatMap {
        do {
          // if the item parses as a single element, return it (as an array for flattening)
          let x: Self = try $0.x()
          return [x]
        }
        catch {
          // if that item doesn't parse, try parsing the item as an array of elements
          let e = error
          do {
            // if it parses as an array, return that array
            let arr: [Self] = try $0.xform(jsArrayRules + [defaultArrayRule()])
            return arr
          }
          catch {
            // but if it doesn't parse, throw the error from parsing THE FIRST ELEMENT,
            // rather than the error from parsing an array
            // WHY?
            // because that's a "deeper" error and more likely to yield useful debug info.
            throw e
          }
        }
      }
    })
  }
  
}

// for now this is just a dummy for rule parsing...
enum JsFn: JsParsable {
  static let jsRules: [JsParseRule<Self>] = []
  
  static func matches(_ x: JSValue) -> Bool { x.isFn }
}

enum JsObj: JsParsable {
  static let jsRules: [JsParseRule<Self>] = []
}

extension Array: JsParsable where Element: JsParsable {
  public static var jsRules: [JsParseRule<Self>] {
    Element.jsArrayRules + [Element.defaultArrayRule()]
  }
  
  public static func matches(_ x: JSValue) -> Bool {
    x.isArray
  }
  
  public static func jsName() -> String {
    "[\(Element.jsName())]"
  }

}

extension Dictionary: JsParsable where Key: JsParsable, Value: JsParsable {
  public static var jsRules: [JsParseRule<Self>] {
    [
      .t([[JsObj]].self, {
        try $0.map {
          try [$0.x(0) : $0.x(1)]
        }.dict { $0 }
      }),
    ]
  }
  
  public static func jsName() -> String {
    "[\(Key.jsName()):\(Value.jsName())]"
  }

}

public protocol JsBankParsable: PatchTruss {
  static var nuJsBankRules: [JsParseRule<SomeBankTruss<Self>>] { get }
}

extension SomeBankTruss: JsParsable where PT: JsBankParsable {
  public static var jsRules: [JsParseRule<Self>] { PT.nuJsBankRules }
}

extension String: JsParsable {
  public static let jsRules: [JsParseRule<Self>] = [
    .t(String.self, {
      guard $0.isString else {
        throw JSError.error(msg: "Expected String")
      }
      return $0.toString()
    }),
  ]

  public static var jsArrayRules: [JsParseRule<[Self]>] = [
    .arr([Int.self, IsoFS.self], {
      let count: Int = try $0.x(0)
      let iso: IsoFS = try $0.x(1)
      return (count).map { iso.forward(Float($0)) }
    }),
  ]
  
  public static func matches(_ x: JSValue) -> Bool {
    x.isString
  }
}


extension Int: JsParsable {
  public static let jsRules: [JsParseRule<Self>] = [
    .t(Int.self, { try $0.num().intValue }),
  ]

  public static func matches(_ x: JSValue) -> Bool {
    x.isNumber
  }
}


extension UInt8: JsParsable {
  public static let jsRules: [JsParseRule<Self>] = [
    .t(Int.self, { try $0.num().uint8Value }),
  ]
  
  public static func matches(_ x: JSValue) -> Bool {
    x.isNumber
  }

}

extension Float: JsParsable {
  public static let jsRules: [JsParseRule<Self>] = [
    .t(Float.self, { try $0.num().floatValue }),
  ]
  
  public static func matches(_ x: JSValue) -> Bool {
    x.isNumber
  }

}

extension CGFloat: JsParsable {
  public static let jsRules: [JsParseRule<Self>] = [
    .t(CGFloat.self, { CGFloat(truncating: try $0.num()) }),
  ]
  
  public static func matches(_ x: JSValue) -> Bool {
    x.isNumber
  }

}

extension Bool: JsParsable {
  public static let jsRules: [JsParseRule<Self>] = [
    .t(Bool.self, {
      guard $0.isBoolean else { throw JSError.error(msg: "Expected Boolean") }
      return $0.toBool()
    }),
  ]
  
  public static func matches(_ x: JSValue) -> Bool {
    x.isBoolean
  }

}

extension ClosedRange : JsParsable where Bound: JsParsable {
  public static var jsRules: [JsParseRule<Self>] {
    [
      .arr([Int.self, Int.self], {
//        if Bound.self == Int.self {
//          let lower: Int = try $0.x(0)
//          let upper: Int = try $0.x(1) - 1
//          return (lower as! Bound)...(upper as! Bound)
//        }
//        else {
          return try ($0.x(0))...($0.x(1))
//        }
      }),
    ]
  }
}
