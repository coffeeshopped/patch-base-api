
public struct RolandAddress : ExpressibleByIntegerLiteral, Hashable, Comparable {

  public static func < (lhs: RolandAddress, rhs: RolandAddress) -> Bool {
    lhs.value < rhs.value
  }

  public static func + (left: RolandAddress, right: RolandAddress) -> RolandAddress {
    self.init(intValue: left.intValue() + right.intValue())
  }

  // NO! Doing this makes the compiler interpret a bunch of literals that I *meant* as RolandAddress as Int instead (duh).
//  public static func + (left: RolandAddress, right: Int) -> RolandAddress {
//    self.init(intValue: left.intValue() + right)
//  }

  public static func - (left: RolandAddress, right: RolandAddress) -> RolandAddress {
    self.init(intValue: left.intValue() - right.intValue())
  }

  public static func * (left: RolandAddress, right: Int) -> RolandAddress {
    self.init(intValue: left.intValue() * right)
  }

  public static func * (left: Int, right: RolandAddress) -> RolandAddress {
    right * left
  }

  public static func / (left: RolandAddress, right: RolandAddress) -> Int {
    left.intValue() / right.intValue()
  }

  public typealias IntegerLiteralType = Int
  
  // must be converted before offsetting can happen!
  /// The value of the address as given in the manual
  public var value: Int
  
  public init(integerLiteral value: Int) {
    self.init(value)
  }
  
  /// Init with the value from the manual
  public init(_ v: Int) {
    value = v
  }
  
  /// Init with byte array, MSB first (Roland-style)
  public init(_ bytes: [UInt8]) {
    self.init(Int(msbFirst: bytes))
  }
  
  /// Init from an int value that needs to be converted
  public init(intValue: Int) {
    // take each 7 bits
//    value = 0
//    for i in 0..<4 {
//      let bitsVal = (intValue >> (i*7)) & 0x7f
//      value += bitsVal << (i * 8)
//    }
    
    var bitsVal = (intValue) & 0x7f
    value = bitsVal
    bitsVal = (intValue >> 7) & 0x7f
    value += bitsVal << 8
    bitsVal = (intValue >> 14) & 0x7f
    value += bitsVal << 16
    bitsVal = (intValue >> 21) & 0x7f
    value += bitsVal << 24
  }
  
  public func intValue() -> Int {
    // take each byte
    // assumes no longer than a 4-byte address!
//    var intVal = 0
//    for i in 0..<4 {
//      // get the i-th byte (from LSB)
//      let byteVal = (value >> (i * 8)) & 0xff
//      // add just the the lower 7 bits of each byte
//      intVal += (byteVal.bits(0...6) << (i * 7))
//    }
    
    var byteVal = value & 0x7f
    var intVal = byteVal
    byteVal = (value >> 8) & 0x7f
    intVal += (byteVal << 7)
    byteVal = (value >> 16) & 0x7f
    intVal += (byteVal << 14)
    byteVal = (value >> 24) & 0x7f
    intVal += (byteVal << 21)

    return intVal
  }
    
  /// Convert value to byte array, MSB first, for sysex sending
  public func sysexBytes(count: Int) -> [UInt8] {
    return (1...count).map {
      let shift = 8 * (count - $0)
      return UInt8((value >> shift) & 0xff)
    }
  }
  
  public func hexString(count: Int) -> String {
    let b = sysexBytes(count: count)
    return b.reduce("", { $0 + String(format:"%02X", $1) })
  }
}

public extension Int {
  
  init(msbFirst bytes: [UInt8]) {
    var v = 0
    bytes.forEach { v = (v << 8) | Int($0) }
    self.init(v)
  }
  
  /// Decompose into byte array, MSB-first
  func bytes(count: Int) -> [UInt8] {
    var b = [UInt8](repeating: 0, count: count)
    for i in 0..<count {
      b[i] = UInt8((self >> ((-1+count-i)*8)) & 0xff)
    }
    return b
  }
  
  /// Decompose into byte array, 7 bits at a time, MSB-first
  func bytes7bit(count: Int) -> [UInt8] {
    return (1...count).map {
      let shift = (count - $0) * 7
      return UInt8((self >> shift) & 0x7f)
    }
  }
  
}
