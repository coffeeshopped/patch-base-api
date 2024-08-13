
public extension Int {
  func map(inRange: ClosedRange<Int>, outRange: ClosedRange<Int>) -> Int {
    let frac = Float(self - inRange.lowerBound)/Float(inRange.upperBound-inRange.lowerBound)
    return Int((frac*Float(outRange.upperBound-outRange.lowerBound)).rounded()) + outRange.lowerBound
  }
}

public extension UInt8 {
  
  @available(*, deprecated, renamed: "set")
  func setBit(_ bit: Int, value: Int) -> UInt8 {
    var b = Int(self)
    // clear the bit
    b &= ~(1 << bit)
    // set the bit (if 1)
    b |= ((value & 1) << bit)
    return UInt8(b)
  }

  func set(bit: Int, value: Int) -> UInt8 {
    var b = Int(self)
    // clear the bit
    b &= ~(1 << bit)
    // set the bit (if 1)
    b |= ((value & 1) << bit)
    return UInt8(b)
  }

  
  func set(bits: ClosedRange<Int>, value: Int) -> UInt8 {
    let bitlen = 1 + (bits.upperBound - bits.lowerBound)
    let bitmask = (1 << bitlen) - 1 // all 1's
    var b = Int(self)
    // clear the bits
    b &= ~(bitmask << bits.lowerBound)
    // set the bits
    b |= ((value & bitmask) << bits.lowerBound)
    return UInt8(b)
  }
  
  @available(*, deprecated, renamed: "bit")
  func getBit(_ bit: Int) -> Int {
    return (Int(self) >> bit) & 1
  }

  func bit(_ b: Int) -> Int {
    return Int(bit(b) as UInt8)
  }

  func bit(_ bit: Int) -> UInt8 {
    return (self >> bit) & 1
  }

  func bits(_ bits: ClosedRange<Int>) -> Int {
    let bitlen = 1 + (bits.upperBound - bits.lowerBound)
    let bitmask = (1 << bitlen) - 1 // all 1's
    return (Int(self) >> bits.lowerBound) & bitmask
  }
  
  func signedBits(_ bits: ClosedRange<Int>) -> Int {
    let unsigned = self.bits(bits)
    let bitlen = 1 + (bits.upperBound - bits.lowerBound)
    // propagate the top bit if 1
    if self.bit(bits.upperBound) == 1 {
      return Int(Int8(bitPattern: ((0xff >> bitlen) << bitlen) | UInt8(unsigned)))
    }
    else {
      return unsigned
    }
  }

}

public extension Int {
  
  func set(bits: ClosedRange<Int>, value: Int) -> Int {
    let bitlen = 1 + (bits.upperBound - bits.lowerBound)
    let bitmask = (1 << bitlen) - 1 // all 1's
    var b = self
    // clear the bits
    b &= ~(bitmask << bits.lowerBound)
    // set the bits
    b |= ((value & bitmask) << bits.lowerBound)
    return b
  }

  func set(bits: ClosedRange<Int>, value: UInt8) -> Int {
    return set(bits: bits, value: Int(value))
  }
    
  func set(bit: Int, value: Int) -> Int {
    return set(bits: bit...bit, value: value)
  }
  
  func bit(_ bit: Int) -> Int {
    return bits(bit...bit)
  }

  func bit(_ bit: Int) -> UInt8 {
    return UInt8(bits(bit...bit))
  }

  func bits(_ bits: ClosedRange<Int>) -> Int {
    let bitlen = 1 + (bits.upperBound - bits.lowerBound)
    let bitmask = (1 << bitlen) - 1 // all 1's
    return (self >> bits.lowerBound) & bitmask
  }

  func signedBits(_ bits: ClosedRange<Int>) -> Int {
    let unsigned = self.bits(bits)
    let bitlen = 1 + (bits.upperBound - bits.lowerBound)
    // propagate the top bit if 1
    if self.bit(bits.upperBound) == 1 {
      return Int(Int32(bitPattern: ((0xffffffff >> bitlen) << bitlen) | UInt32(unsigned)))
    }
    else {
      return unsigned
    }
  }

  /// Create Int8 from lower 8 bits
  func int8() -> Int8 {
    return self < 0 ? Int8(self) : Int8(bitPattern: UInt8(self))
  }

  /// Create Int8 from lower 8 bits
  func int8() -> Int {
    return Int(int8() as Int8)
  }

  /// Create Int16 from lower 16 bits
  func int16() -> Int16 {
    return self < 0 ? Int16(self) : Int16(bitPattern: UInt16(self))
  }
  
  /// Create Int16 from lower 16 bits
  func int16() -> Int {
    return Int(int16() as Int16)
  }

}

public extension Data {
  
  // unpack bytes in Data in a given range (or the whole data if range not specified)
  // unpacks 8 bytes to 7 bytes where first byte holds top bits for the next 7 bytes (e.g. DSI, Korg)
  // AKA "Packed MS bit" format
  /// count: expected output byte length
  func unpack87(count c: Int, inRange r: Range<Int>?) -> [UInt8] {
    let range = r ?? (0..<c)
    var unpacked = [UInt8](repeating: 0, count: c)
    guard range.upperBound <= count else { return unpacked }
    
    // unpack the bytes
    let dataBytes = subdata(in: range)
    
    var byteIndex = 0
    for i in 0..<range.count where i % 8 == 0 {
      let topByte = dataBytes[i]
      
      (1...7).forEach {
        if i + $0 < dataBytes.count && byteIndex < unpacked.count {
          unpacked[byteIndex] = (topByte.bit($0 - 1) << 7) + (dataBytes[i + $0] & 0x7f)
          byteIndex += 1
        }
      }
    }
    return unpacked
  }
  
  mutating func append78(bytes: [UInt8], count outCount: Int) {
    var b = [UInt8](repeating: 0, count: outCount) // outgoing nibbles
    
    var byteIndex = 0
    for i in (0..<bytes.count) where i % 7 == 0 {
      let topByteIndex = byteIndex
      byteIndex += 1
      b[topByteIndex] = 0
      
      for j in 0..<7 {
        let paramByteIndex = i+j
        if paramByteIndex < bytes.count {
          let byteVal = bytes[paramByteIndex]
          b[byteIndex] = byteVal & 0x7f
          b[topByteIndex] = b[topByteIndex] + ((byteVal >> 7) << UInt8(j))
          byteIndex += 1
        }
      }
    }
    append(contentsOf: b)
  }
  
  static func pack78(bytes: [UInt8], count outCount: Int) -> Data {
    var b = [UInt8](repeating: 0, count: outCount) // outgoing nibbles
    
    var byteIndex = 0
    for i in 0..<bytes.count where i % 7 == 0 {
      let topByteIndex = byteIndex
      byteIndex += 1
      b[topByteIndex] = 0
      
      for j in 0..<7 {
        let paramByteIndex = i+j
        guard paramByteIndex < bytes.count, byteIndex < outCount else { continue }

        let byteVal = bytes[paramByteIndex]
        b[byteIndex] = byteVal & 0x7f
        b[topByteIndex] = b[topByteIndex] + ((byteVal >> 7) << UInt8(j))
        byteIndex += 1
      }
    }
    return Data(b)
  }
    
}

public extension Array where Element == UInt8 {
  
  // unpack bytes in Data in a given range (or the whole data if range not specified)
  // unpacks 8 bytes to 7 bytes where first byte holds top bits for the next 7 bytes (e.g. DSI, Korg)
  // AKA "Packed MS bit" format
  /// count: expected output byte length
  func unpack87(count c: Int, inRange r: Range<Int>?) -> Self {
    let range = r ?? (0..<c)
    var unpacked = [UInt8](repeating: 0, count: c)
    guard range.upperBound <= count else { return unpacked }
    
    // unpack the bytes
    let dataBytes = [UInt8](self[range])
    
    var byteIndex = 0
    for i in 0..<range.count where i % 8 == 0 {
      let topByte = dataBytes[i]
      
      (1...7).forEach {
        if i + $0 < dataBytes.count && byteIndex < unpacked.count {
          unpacked[byteIndex] = (topByte.bit($0 - 1) << 7) + (dataBytes[i + $0] & 0x7f)
          byteIndex += 1
        }
      }
    }
    return unpacked
  }
  
  func pack78(count outCount: Int) -> [UInt8] {
    var b = [UInt8](repeating: 0, count: outCount) // outgoing nibbles
    
    var byteIndex = 0
    for i in 0..<count where i % 7 == 0 {
      let topByteIndex = byteIndex
      byteIndex += 1
      b[topByteIndex] = 0
      
      for j in 0..<7 {
        let paramByteIndex = i+j
        guard paramByteIndex < count, byteIndex < outCount else { continue }

        let byteVal = self[paramByteIndex]
        b[byteIndex] = byteVal & 0x7f
        b[topByteIndex] = b[topByteIndex] + ((byteVal >> 7) << UInt8(j))
        byteIndex += 1
      }
    }
    return b
  }
  
  func cleanString() -> String {
    let cleaned = filter { (32...126).contains($0) }
    return String(data: Data(cleaned), encoding: .ascii)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
  }

  func hexString() -> String {
    map { String(format: "%02hhX", $0) }.joined(separator: " ")
  }

}

public extension Data {
  
  /// Like unpack87 but with MSB's in reverse order. Used by Micron/MiniAK
  func unpackR87(count c: Int, inRange r: Range<Int>?) -> [UInt8] {
    let range = r ?? (0..<c)
    
    // unpack the bytes
    let dataBytes = subdata(in: range)
    var unpacked = [UInt8](repeating: 0, count: c)
    
    var byteIndex = 0
    for i in 0..<range.count where i % 8 == 0 {
      if i >= dataBytes.count { continue }
      
      let topByte = dataBytes[i]
      (1...7).forEach { boff in
        guard i + boff < dataBytes.count,
          byteIndex < unpacked.count else { return }
        unpacked[byteIndex] = (topByte.bit(7 - boff) << 7) + dataBytes[i + boff]
        byteIndex += 1
      }
    }
    return unpacked
  }
  
  /// Like append78 but with MSB's in reverse order. Used by Micron/MiniAK
  mutating func appendR78(bytes: [UInt8], count outCount: Int) {
    var b = [UInt8](repeating: 0, count: outCount) // outgoing nibbles
    
    var byteIndex = 0
    for i in (0..<bytes.count) where i % 7 == 0 {
      let topByteIndex = byteIndex
      byteIndex += 1
      b[topByteIndex] = 0
      
      (0..<7).forEach { j in
        let paramByteIndex = i + j
        guard paramByteIndex < bytes.count else { return }
        let byteVal = bytes[paramByteIndex]
        b[byteIndex] = byteVal & 0x7f
        b[topByteIndex] = b[topByteIndex].set(bit: 6 - j, value: byteVal.bit(7))
        byteIndex += 1
      }
    }
    append(contentsOf: b)
  }
    
}

public extension Array where Element == UInt8 {
  
  /// Like unpack87 but with MSB's in reverse order. Used by Micron/MiniAK
  func unpackR87(count c: Int, inRange r: Range<Int>?) -> Self {
    let range = r ?? (0..<c)
    
    // unpack the bytes
    let dataBytes = [UInt8](self[range])
    var unpacked = [UInt8](repeating: 0, count: c)
    
    var byteIndex = 0
    for i in 0..<range.count where i % 8 == 0 {
      let topByte = dataBytes[i]
      (1...7).forEach { boff in
        guard i + boff < dataBytes.count,
          byteIndex < unpacked.count else { return }
        unpacked[byteIndex] = (topByte.bit(7 - boff) << 7) + dataBytes[i + boff]
        byteIndex += 1
      }
    }
    return unpacked
  }
  
}

public extension Data {
  
  func paddedTo(length: Int) -> Data {
    guard count < length else { return self }
    var d = Data(self)
    let pad = [UInt8](repeating: 0, count: length - count)
    d.append(contentsOf: pad)
    return d
  }
  
  // zero-pad the Data if necessary to avoid out of bounds errors
  // used by patch init() methods often
  // returns as UInt8 array instead of data so the indexes are what we expect
  func safeBytes(_ r: Range<Int>) -> [UInt8] {
    return [UInt8](paddedTo(length: r.upperBound)[r])
  }
  
  func bytes() -> [UInt8] { [UInt8](self) }

}

public extension String {
  
  // return [UInt8] for given count, padded with spaces if necessary
  func bytes(forCount count: Int) -> [UInt8] {
    var bytes = [UInt8]()
    let n = self as NSString
    for i in 0..<count {
      let b: UInt8 = i < n.length ? UInt8(n.character(at: i)) : 32 // space
      bytes.append(b)
    }
    return bytes
  }
  
  func sysexBytes() -> [UInt8] { unicodeScalars.map { UInt8($0.value) } }
  
}

public extension RandomAccessCollection {
  
  func random() -> Iterator.Element? {
    guard !isEmpty else { return nil }
    let offset = arc4random_uniform(numericCast(count))
    let i = index(startIndex, offsetBy: numericCast(offset))
    return self[i]
  }
  
}

public extension Int {
  /// Return random number between 0 and 1 less than self
  func rand() -> Int {
    if self > 0 {
      return Int(arc4random_uniform(numericCast(self)))
    }
    else if self == 0 {
      return 0
    }
    else {
      return -1 * Int(arc4random_uniform(numericCast(-1 * self)))
    }
  }
  
  func times(fn: () -> Void) {
    (0..<self).forEach { _ in fn() }
  }

  func times(fn: (Int) -> Void) {
    (0..<self).forEach { fn($0) }
  }
  
  func map<T>(fn: () -> T) -> [T] {
    (0..<self).map { _ in fn() }
  }
  
  func map<T>(fn: (Int) -> T) -> [T] {
    (0..<self).map { fn($0) }
  }

  func map<T>(fn: (Int) throws -> T) throws -> [T] {
    try (0..<self).map { try fn($0) }
  }

  func compactMap<T>(fn: (Int) -> T?) -> [T] {
    (0..<self).compactMap { fn($0) }
  }

  func forEach(fn: (Int) -> Void) -> Void {
    (0..<self).forEach { fn($0) }
  }

  func flatMap<T>(fn: (Int) -> [T]) -> [T] {
    (0..<self).flatMap { fn($0) }
  }

  func flatMap<T>(fn: (Int) throws -> [T]) throws -> [T] {
    try (0..<self).flatMap { try fn($0) }
  }

  func dict<K, V>(transform:(_ i: Self) -> [K : V]) -> [K : V] {
    map { transform($0) }.reduce([:], <<<)
  }

  func compactDict<K, V>(transform:(_ i: Self) -> [K : V]?) -> [K : V] {
    compactMap { transform($0) }.reduce([:], <<<)
  }

  func zPad(_ length: Int) -> String {
    String(format: "%0\(length)d", self)
  }

}

public extension RandomAccessCollection where Iterator.Element == Int {
  func rand() -> Int {
    guard !isEmpty else { return 0 }
    let offset = arc4random_uniform(numericCast(count))
    let i = index(startIndex, offsetBy: numericCast(offset))
    return self[i]
  }
}

public extension Array where Element == UInt8 {
  
  func sevenToEightStraight() -> [UInt8] {
//    if (e.length % 8 != 0) throw "Buffer needs to be divisible by 8";
    let chunks = count / 8
    var n = [UInt8](repeating: 0, count: chunks * 7)
    (0..<chunks).forEach {
      let off = $0 * 8
      let writeOff = $0 * 7
      n[writeOff] = ((self[off + 0] & 0x7f) << 1) + (self[off + 1] >> 6)
      n[writeOff + 1] = ((self[off + 1] & 0x3f) << 2) + (self[off + 2] >> 5)
      n[writeOff + 2] = ((self[off + 2] & 0x1f) << 3) + (self[off + 3] >> 4)
      n[writeOff + 3] = ((self[off + 3] & 0x0f) << 4) + (self[off + 4] >> 3)
      n[writeOff + 4] = ((self[off + 4] & 0x07) << 5) + (self[off + 5] >> 2)
      n[writeOff + 5] = ((self[off + 5] & 0x03) << 6) + (self[off + 6] >> 1)
      n[writeOff + 6] = ((self[off + 6] & 0x01) << 7) + (self[off + 7])
    }
    return n
  }
  
  func eightToSevenStraight() -> [UInt8] {
//      if (e.length % 7 != 0) throw "Buffer needs to be divisible by 7";
    let chunks = count / 7
    var t = [UInt8](repeating: 0, count: chunks * 8)
    (0..<chunks).forEach {
      let off = $0 * 7
      let writeOff = $0 * 8
      t[writeOff + 0] = self[off + 0] >> 1 & 127
      t[writeOff + 1] = ((self[off + 0] & 0x01) << 6) + (self[off + 1] >> 2)
      t[writeOff + 2] = ((self[off + 1] & 0x03) << 5) + (self[off + 2] >> 3)
      t[writeOff + 3] = ((self[off + 2] & 0x07) << 4) + (self[off + 3] >> 4)
      t[writeOff + 4] = ((self[off + 3] & 0x0f) << 3) + (self[off + 4] >> 5)
      t[writeOff + 5] = ((self[off + 4] & 0x1f) << 2) + (self[off + 5] >> 6)
      t[writeOff + 6] = ((self[off + 5] & 0x3f) << 1) + (self[off + 6] >> 7)
      t[writeOff + 7] = self[off + 6] & 0x7f
    }
    return t
  }
  
  func data() -> Data { Data(self) }
  
  func paddedTo(length: Int, value: UInt8? = nil) -> [UInt8] {
    guard count < length else { return self }
    return self + [UInt8](repeating: value ?? 0, count: length - count)
  }

  // zero-pad the Data if necessary to avoid out of bounds errors
  // used by patch init() methods often
  // returns as UInt8 array instead of data so the indexes are what we expect
  func safeBytes(_ r: Range<Int>) -> [UInt8] {
    [UInt8](paddedTo(length: r.upperBound)[r])
  }
  
  func safeBytes(offset: Int, count c: Int) -> [UInt8] {
    safeBytes(offset..<(offset + c))
  }

}

public extension UInt8 {

  func flatMap<T>(fn: (Self) -> [T]) -> [T] {
    (0..<self).flatMap { fn($0) }
  }

  func flatMap<T>(fn: (Self) throws -> [T]) throws -> [T] {
    try (0..<self).flatMap { try fn($0) }
  }

}
