
public let RolandDefaultDeviceId = 16

public func RolandChecksum(address: RolandAddress, dataBytes data: [UInt8], addressCount: Int) -> UInt8 {
  var total = 0
  address.sysexBytes(count: addressCount).forEach { total += Int($0) }
  data.forEach { total += Int($0) }
  return UInt8(0x7f & (128 - (total % 128)))
}

public enum Roland {
  
}

public extension Roland {
  
  /**
   MSB-first packing/unpacking of a multi-byte parameter
   */
  static func msbMultiPackIso(_ byteCount: Int) -> ((_ byte: RolandAddress) -> PackIso) {
    { byte in
      PackIso.splitter(byteCount.map {
        let loValBit = (byteCount - ($0 + 1)) * 4
        let hiValBit = loValBit + 3
        return (byte: (byte + RolandAddress(intValue: $0)).intValue(), byteBits: 0...3, valueBits: loValBit...hiValBit)
      })
    }
  }
}

public extension Parm {
  
  static func p(_ path: SynthPath, _ b: RolandAddress, packIso: PackIso? = nil, _ span: Span = .rng()) -> Self {
    .init(path: path, b: b.value, packIso: packIso, span: span)
  }

}

public extension Array where Element == Parm {

  static func prefix(_ pfx: SynthPath, count: Int, bx: RolandAddress, block: @escaping ((_ index: Int, _ offset: RolandAddress) -> Self)) -> Self {
    (0..<count).flatMap { i in
      let off = bx * i
      let blockArr = block(i, off)
      return blockArr.offset(b: off).prefix(pfx + [.i(i)])
    }
  }
  
  func offset(b: RolandAddress) -> Self {
    map {
      var newOpts = $0
      if let bb = newOpts.b {
        newOpts.b = (RolandAddress(bb) + b).value
      }
      return newOpts
    }
  }
  
//  static func inc(b: Int? = nil, p: Int? = nil, inc: Int = 1, block: @escaping (() -> Self)) -> Self {
//    let blockPairs = block()
//    return blockPairs.enumerated().map {
//      var newOpts = $0.element
//      if let b = b {
//        newOpts.b = b + $0.offset * inc
//      }
//      if let p = p {
//        newOpts.p = p + $0.offset * inc
//      }
//      return newOpts
//    }
//  }
  
}
