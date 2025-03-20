
import PBAPI

extension PackIso : JsParsable {
  
  static let jsRules: [JsParseRule<Self>] = [
    .a(["splitter", ".a"], { try .splitter($0.x(1)) }),
  ]
}

extension PackIso.Blitter : JsArrayParsable {
  
  static let jsRules: [JsParseRule<Self>] = [
    .d([
      "byte" : ".n",
      "byteBits" : ".a?",
      "valueBits" : ".a",
    ], {
      try .init(byte: $0.x("byte"), byteBits: $0.xq("byteBits"), valueBits: $0.x("valueBits"))
    })
  ]
  
  static let jsArrayParsers = try! jsParsers.arrayParsers()
}
