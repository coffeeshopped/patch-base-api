
public struct SingleBankTrussWerk {
  
}

public extension SingleBankTrussWerk {
  
  static func compactData(fileData: [UInt8], offset: Int, patchByteCount: Int) -> [[UInt8]] {
    return stride(from: offset, to: fileData.count, by: patchByteCount).compactMap { doff in
      let endex = doff + patchByteCount
      guard endex <= fileData.count else { return nil }
      return [UInt8](fileData[doff..<endex])
    }
  }

  static func singleSortedByteArrays(sysexData: [UInt8], count: Int, locationMap: ([UInt8]) -> Int) -> [[UInt8]] {
    var sysexDict = [Int:[UInt8]]()
    SysexData(data: sysexData.data()).forEach {
      let d = [UInt8]($0)
      sysexDict[locationMap(d)] = d
    }
    return count.map { sysexDict[$0] ?? [] }
  }

  static func singleSortedByteArrays(sysexData: [UInt8], count: Int, locationByteIndex: Int) -> [[UInt8]] {
    singleSortedByteArrays(sysexData: sysexData, count: count, locationMap: { Int($0[locationByteIndex]) })
  }
    
  /// Set parseBodyData to sort sysex messages based on value at locationIndex, then parse each message using the patchTruss 
  /// parseBodyData fn
  static func sortAndParseBodyDataWithLocationIndex<PT:PatchTruss>(_ locationIndex: Int, patchTruss: PT, patchCount: Int) -> SomeBankTruss<PT>.Core.ParseBodyDataFn {
    {
      try singleSortedByteArrays(sysexData: $0, count: patchCount, locationByteIndex: locationIndex).map { try patchTruss.parseBodyData($0) }
    }
  }

  static func sortAndParseBodyDataWithLocationMap<PT:PatchTruss>(_ locationMap: @escaping ([UInt8]) -> Int, patchTruss: PT, patchCount: Int) -> SomeBankTruss<PT>.Core.ParseBodyDataFn {
    {
      try singleSortedByteArrays(sysexData: $0, count: patchCount, locationMap: locationMap).map { try patchTruss.parseBodyData($0) }
    }
  }

  static func createFileDataWithLocationMap(_ fn: @escaping (SinglePatchTruss.BodyData, Int) -> [UInt8]) -> SingleBankTruss.Core.ToMidiFn {
    { b, e in b.enumerated().flatMap { fn($0.element, $0.offset) } }
  }

  static func createFileDataWithLocationMap(_ fn: @escaping (SinglePatchTruss.BodyData, Int) throws -> [UInt8]) -> SingleBankTruss.Core.ToMidiFn {
    { b, e in try b.enumerated().flatMap { try fn($0.element, $0.offset) } }
  }

}
