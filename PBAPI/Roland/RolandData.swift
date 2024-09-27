
public struct RolandWerkData {
  
  public let werk: RolandSysexTrussWerk
  public let startAddress: RolandAddress
  public let endAddress: RolandAddress
  private let slab: Data
  
  public init(data: Data, werk: RolandSysexTrussWerk) {
    self.init(sysexData: SysexData(data: data).map { $0 }, werk: werk)
  }
  
  public init(sysexData: [Data], werk: RolandSysexTrussWerk) {
    self.werk = werk
    
    guard sysexData.count > 0 else {
      startAddress = 0x0
      endAddress = 0x0
      slab = Data()
      return
    }

    let minMsgCount = werk.parseOffset + 2
    // sort by address
    // filter msgs that are too short (e.g. D-50 handshake banks)
    // data set header length + checksum + 0xf7
    let msgs = sysexData.sorted {
      werk.address(forSysex: $0.bytes()) < werk.address(forSysex: $1.bytes())
    }.filter { $0.count >= minMsgCount }
    // get the first address as start address
    startAddress = werk.address(forSysex: msgs.first!.bytes())
    
    // figure out the needed slab size
    let last = msgs.last!
    let lastSize = RolandAddress(intValue: (werk.parseOffset..<(last.count - 2)).count)
    endAddress = werk.address(forSysex: last.bytes()) + lastSize
    var s = Data(count: (endAddress - startAddress).intValue())
    let start = startAddress
    msgs.forEach {
      let content = Data($0[werk.parseOffset..<($0.count - 2)])
      let offset = (werk.address(forSysex: $0.bytes()) - start).intValue()
      s.replaceSubrange(offset..<(offset+content.count), with: content)
    }
    slab = s    
  }
  
  public func data(forAddress address: RolandAddress, size: RolandAddress) -> [UInt8] {
    bytes(offset: address - startAddress, size: size)
  }
  
  public func bytes(offset: RolandAddress, size: RolandAddress) -> [UInt8] {
    let offset = offset.intValue()
    let offsetEnd = offset + size.intValue()
    guard offsetEnd <= slab.count else { return [UInt8](repeating: 0, count: offsetEnd - offset) }
    return [UInt8](slab[offset..<offsetEnd])
  }
  
  /// Render this as an array of sysex msgs with given deviceId, offset address to be added to slab addresses, and msg size (default 256)
  public func sysexMsgs(deviceId: Int, offsetAddress: RolandAddress = 0x0, msgContentSize: RolandAddress = 0x200) -> [[UInt8]] {
    var slabAddress = startAddress
    var d = [[UInt8]]()
    while slabAddress < endAddress {
      let size: RolandAddress = min((endAddress - slabAddress), msgContentSize)
      let b = [UInt8](data(forAddress: slabAddress, size: size))
      let nextAddress = offsetAddress + slabAddress
      d.append(werk.sysexMsg(deviceId: UInt8(deviceId), address: nextAddress, bytes: b))
      slabAddress = slabAddress + size
    }
    return d
  }
  
  
}
