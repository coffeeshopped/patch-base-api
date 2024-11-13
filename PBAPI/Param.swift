
public typealias ParamValueFormatter = ((Int) -> String)
public typealias ParamValueParser = ((String) -> Int)
public typealias ParamValueMapper = (format: ParamValueFormatter, parse: ParamValueParser)

public extension IsoFS {

  func pvm() -> ParamValueMapper {
    (
      format: { forward(Float($0)) },
      parse: { Int(round(backward($0))) }
    )
  }

}

public struct OptionsParam {
  public static func makeOptions(_ values: [String]) -> [Int:String] {
    return values.enumerated().reduce([Int:String](), { (dict, e) -> [Int:String] in
      var dict = dict
      dict[e.0] = e.1
      return dict
    })
  }

  public static func makeNumberedOptions(_ values: [String], offset: Int = 0) -> [Int:String] {
    return values.enumerated().reduce([Int:String](), { (dict, e) -> [Int:String] in
      var dict = dict
      dict[e.0] = "\(e.0 + offset): \(e.1)"
      return dict
    })
  }

}

extension Dictionary : ExpressibleByArrayLiteral where Key == Int, Value == String {
  public typealias ArrayLiteralElement = String
  
  public init(arrayLiteral elements: String...) {
    self.init()
    elements.enumerated().forEach { self[$0.offset] = $0.element }
  }
}

public extension Dictionary where Key == Int, Value == String {
  func numPrefix(offset: Int = 1) -> Self {
    dict {
      [$0.key : "\($0.key + offset): \($0.value)"]
    }
  }
}
