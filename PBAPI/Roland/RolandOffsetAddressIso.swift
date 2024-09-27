

public struct RolandOffsetAddressIso {
  public let address: (_ location: UInt8) -> RolandAddress
  public let location: (_ address: RolandAddress) -> UInt8
  
  public init(address: @escaping (_ location: UInt8) -> RolandAddress, location: @escaping (_ address: RolandAddress) -> UInt8) {
    self.address = address
    self.location = location
  }
}

public extension RolandOffsetAddressIso {
  
  static func lsByte(_ index: Int, offset: UInt8 = 0) -> Self {
    let shiftBits = index * 8
    return .init { location in
      RolandAddress((Int(location) + Int(offset)) << shiftBits)
    } location: { address in
      UInt8((address.value >> shiftBits) & 0xff) - offset
    }
  }
  
}
