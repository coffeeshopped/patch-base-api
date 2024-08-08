
public class SysexData : Collection {
  public typealias Index = Int
  
  public var startIndex: Index { 0 }
  public var endIndex: Index { messageRanges.count }
  
  public subscript(index: Index) -> Data {
    get { return data.subdata(in: messageRanges[index]) }
  }

  public func index(after i: Index) -> Index { i + 1 }

  private let data: Data
  private let messageRanges: [Range<Int>]
  
  public init(data d: Data) {
    data = d
    
    var ranges = [Range<Int>]()
    var lastStart = -1
    data.enumerated().forEach {
      if $0.element == 0xf0 {
        lastStart = $0.offset
      }
      else if $0.element == 0xf7 && lastStart >= 0 {
        // valid sysex
        ranges.append(lastStart..<$0.offset+1)
        lastStart = -1
      }
    }
    
    messageRanges = ranges
  }
  
}
