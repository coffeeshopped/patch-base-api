
public enum MidiMessage {
  case sysex([UInt8])
  case cc(channel: UInt8, number: UInt8, value: UInt8)
  case pgmChange(channel: UInt8, value: UInt8)
  case noteOn(channel: UInt8, note: UInt8, velocity: UInt8)
  case noteOff(channel: UInt8, note: UInt8, velocity: UInt8)

  public func bytes() -> [UInt8] {
    switch self {
    case .sysex(let data):
      return data
    case .cc(let channel, let number, let value):
      return [0xb0 + UInt8(channel), UInt8(number), UInt8(value)]
    case .pgmChange(let channel, let value):
      return [0xc0 + UInt8(channel), UInt8(value)]
    case .noteOn(let channel, let note, let velocity):
      return [0x90 + channel, note, velocity]
    case .noteOff(let channel, let note, let velocity):
      return [0x80 + channel, note, velocity]
    }
  }
  
  public var count: Int {
    switch self {
    case .sysex(let data):
      return data.count
    case .cc, .noteOn, .noteOff:
      return 3
    case .pgmChange:
      return 2
    }
  }
  
  public func channel(_ ch: UInt8) -> MidiMessage {
    switch self {
    case .sysex:
      return self
    case .cc(_, let number, let value):
      return .cc(channel: ch, number: number, value: value)
    case .pgmChange(_, let value):
      return .pgmChange(channel: ch, value: value)
    case .noteOn(_, let note, let velocity):
      return .noteOn(channel: ch, note: note, velocity: velocity)
    case .noteOff(_, let note, let velocity):
      return .noteOff(channel: ch, note: note, velocity: velocity)
    }
  }
}

public struct Midi {
  
  public static func cc(_ c: Int, value: Int, channel: Int) -> [UInt8] {
    return [0xb0 + UInt8(channel), UInt8(c), UInt8(value)]
  }
  
  public static func nrpn(_ c: Int, value: Int, channel: Int) -> [UInt8] {
    return cc(99, value: (c >> 7) & 0x7f, channel: channel) +
      cc(98, value: c & 0x7f, channel: channel) +
      cc(6, value: value, channel: channel)
  }
  
  public static func pgmChange(_ pgm: Int, channel: Int) -> [UInt8] {
    return [0xc0 + UInt8(channel), UInt8(pgm)]
  }
}
