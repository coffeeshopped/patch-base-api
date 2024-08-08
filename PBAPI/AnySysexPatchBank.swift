
public protocol AnySysexPatchBank : AnySysexible {
  var bankTruss: any BankTruss { get }
  subscript(_ i: Int) -> AnySysexPatch { get set }
  var patchCount: Int { get }
  mutating func swap(_ i1: Int, _ i2: Int)
}

public extension AnySysexPatchBank {
  var patchCount: Int { bankTruss.patchCount }
}
