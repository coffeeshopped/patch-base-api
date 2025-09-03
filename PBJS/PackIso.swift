
import PBAPI

extension PackIso : JsParsable {
  
  static let nuJsRules: [NuJsParseRule<Self>] = [
    .a("splitter", [[Blitter].self], { try .splitter($0.x(1)) }),
  ]
  
  static let jsRules: [JsParseRule<Self>] = [
    .a(["splitter", ".a"], { try .splitter($0.x(1)) }),
  ]
}

extension PackIso.Blitter : JsParsable {

  static let nuJsRules: [NuJsParseRule<Self>] = [
    .d([
      "byte" : Int.self,
      "byteBits?" : ClosedRange<Int>.self,
      "valueBits" : ClosedRange<Int>.self,
    ], {
      try .init(byte: $0.x("byte"), byteBits: $0.xq("byteBits"), valueBits: $0.x("valueBits"))
    })
  ]
  
  static let jsRules: [JsParseRule<Self>] = [
    .d([
      "byte" : ".n",
      "byteBits" : ".a?",
      "valueBits" : ".a",
    ], {
      try .init(byte: $0.x("byte"), byteBits: $0.xq("byteBits"), valueBits: $0.x("valueBits"))
    })
  ]
  
}
