
public extension SomeBankTruss {
  
  static func compactData(fileData: [UInt8], offset: Int, patchByteCount: Int) -> [[UInt8]] {
    return stride(from: offset, to: fileData.count, by: patchByteCount).compactMap { doff in
      let endex = doff + patchByteCount
      guard endex <= fileData.count else { return nil }
      return [UInt8](fileData[doff..<endex])
    }
  }
  
}
