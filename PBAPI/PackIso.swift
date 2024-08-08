
/// A way of creating isomorphisms that map an Int into a [UInt8] and vice versa.
public struct PackIso {
  public let pack: (inout [UInt8], Int) -> Void
  public let unpack: ([UInt8]) -> Int
    
  /**
   Indicates the number of bytes packed/unpacked by this iso. Might not always be strictly applicable, but is helpful in many cases (e.g. Roland multi-byte packing, where the number of bytes is useful when knowing how many bytes to send in a MIDI parameter change message).
   */
  public let byteCount: Int
  
  public init(pack: @escaping (inout [UInt8], Int) -> Void, unpack: @escaping ([UInt8]) -> Int, byteCount: Int = 1) {
    self.pack = pack
    self.unpack = unpack
    self.byteCount = byteCount
  }

  /// Blitter = Byte Splitter
  public typealias Blitter = (
    byte: Int,
    byteBits: ClosedRange<Int>?,
    valueBits: ClosedRange<Int>
  )
}

public func >>>(_ lhs: Iso<Int, Int>, _ rhs: PackIso) -> PackIso {
  return PackIso(pack: { bytes, value in
    rhs.pack(&bytes, lhs.forward(value))
  }, unpack: { bytes in
    lhs.backward(rhs.unpack(bytes))
  }, byteCount: rhs.byteCount)
}

public extension PackIso {
  
  static func byte(_ byte: Int) -> PackIso {
    return PackIso(pack: { bytes, value in
      bytes[byte] = UInt8(value)
    }, unpack: { bytes in
      Int(bytes[byte])
    }, byteCount: 1)
  }
  
  static func splitter(_ blitters: [Blitter]) -> PackIso {
    return PackIso(pack: { bytes, value in
      blitters.forEach {
        let v: UInt8
        if let byteBits = $0.byteBits {
          let setV = value.bits($0.valueBits)
          v = bytes[$0.byte].set(bits: byteBits, value: setV)
        }
        else {
          v = UInt8(value.bits($0.valueBits))
        }
        bytes[$0.byte] = v
      }
    }, unpack: { bytes in
      var value = 0
      blitters.forEach {
        let v: Int
        if let byteBits = $0.byteBits {
          v = bytes[$0.byte].bits(byteBits)
        }
        else {
          v = Int(bytes[$0.byte])
        }
        value = value.set(bits: $0.valueBits, value: v)
      }
      return value
    }, byteCount: blitters.count)

  }
}
