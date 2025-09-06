
import PBAPI

extension PackIso : JsParsable {
  
  public static let jsRules: [JsParseRule<Self>] = [
    .a("splitter", [[Blitter].self], { try .splitter($0.x(1)) }),
  ]
  
}

extension PackIso.Blitter : JsParsable {

  public static let jsRules: [JsParseRule<Self>] = [
    .d([
      "byte" : Int.self,
      "byteBits?" : ClosedRange<Int>.self,
      "valueBits" : ClosedRange<Int>.self,
    ], {
      try .init(byte: $0.x("byte"), byteBits: $0.xq("byteBits"), valueBits: $0.x("valueBits"))
    })
  ]
    
}
