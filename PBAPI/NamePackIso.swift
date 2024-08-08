
public struct NamePackIso {
  public let pack: (inout [UInt8], String) throws -> Void
  public let unpack: ([UInt8]) throws -> String
  public let byteRange: CountableRange<Int>
  
  public init(pack: @escaping (inout [UInt8], String) throws -> Void, unpack: @escaping ([UInt8])  throws -> String, byteRange: CountableRange<Int>) {
    self.pack = pack
    self.unpack = unpack
    self.byteRange = byteRange
  }
}

/// lhs.forward is filter before setting name.
public func >>>(_ lhs: Iso<String, String>, _ rhs: NamePackIso) -> NamePackIso {
  return NamePackIso(pack: { bytes, value in
    try rhs.pack(&bytes, lhs.forward(value))
  }, unpack: { bytes in
    try lhs.backward(rhs.unpack(bytes))
  }, byteRange: rhs.byteRange)
}

public extension NamePackIso {
  
  static func basic(_ range: CountableRange<Int>) -> NamePackIso {
    filtered(range, toBytes: {
      $0.bytes(forCount: range.count)
    }, toName: {
      cleanBytesToString($0)
    })
  }
  
  static func filtered(_ range: CountableRange<Int>, toBytes: @escaping (String) throws -> [UInt8], toName: @escaping ([UInt8]) throws -> String) -> NamePackIso {
    NamePackIso(pack: { bytes, name in
      let sizedName = filtered(name: name, count: range.count)
      guard range.lowerBound >= 0 && range.upperBound <= bytes.count else {
        debugPrint("Bad range for name pack!")
        return
      }
      // transform into bytes
      let nameBytes = try toBytes(sizedName)
      // place the bytes
      bytes.replaceSubrange(range, with: nameBytes)

    }, unpack: { bytes in
      guard bytes.count > 0 && range.clamped(to: 0..<bytes.count) == range else {
        debugPrint("nameByteRange falls outside of patch byte range")
        return ""
      }
      let nameBytes = [UInt8](bytes[range])
      return trimmed(name: try toName(nameBytes))
    }, byteRange: range)
  }
  
  static func filtered(name: String, count: Int) -> String {
    // filter out non-ascii
    let filteredName = String(name.unicodeScalars.filter { $0.isASCII })
    // make the name the size that fits
    let sizedName = filteredName.padding(toLength: count, withPad: " ", startingAt: 0)
    return sizedName
  }
  
  static func trimmed(name: String) -> String {
    name.trimmingCharacters(in: .whitespacesAndNewlines)
  }
  
  static func cleanBytesToString(_ bytes: [UInt8]) -> String {
    let cleanedData = bytes.filter { (32...126).contains($0) }
    return String(bytes: cleanedData, encoding: .ascii) ?? ""
  }
}
