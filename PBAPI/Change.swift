
public protocol Change {
  associatedtype Sysex
  
  static func replace(_ sysex: Sysex) -> (Self, Sysex?)
}
