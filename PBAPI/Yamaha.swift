
public enum Yamaha {
}

public extension Yamaha {
  
  static func checksum(bytes: [UInt8]) -> UInt8 {
    let byteSum = bytes.map{ Int($0) }.reduce(0, +)
    return UInt8((-1 * byteSum) & 0x7f)
  }

  static func sysex(_ bytes: [UInt8]) -> [UInt8] {
    [0xf0, 0x43] + bytes + [0xf7]
  }

  static func sysexData(channel: Int, cmdBytes: [UInt8], bodyBytes: [UInt8]) -> [UInt8] {
    sysexData(cmdBytesWithChannel: [UInt8(channel)] + cmdBytes, bodyBytes: bodyBytes)
  }

  static func sysexData(cmdBytesWithChannel: [UInt8], bodyBytes: [UInt8]) -> [UInt8] {
    sysex(cmdBytesWithChannel + bodyBytes + [checksum(bytes: bodyBytes)])
  }

  static func paramData(channel: Int, cmdBytes: [UInt8]) -> [UInt8] {
    sysex([0x10 + UInt8(channel)] + cmdBytes)
  }
  
  static func fetchRequestBytes(channel: Int, cmdBytes: [UInt8]) -> [UInt8] {
    sysex([0x20 + UInt8(channel)] + cmdBytes)
  }
  
}
