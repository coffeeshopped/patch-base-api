
public protocol BankTruss : SysexTruss {
  var anyPatchTruss: any PatchTruss { get }
  var patchCount: Int { get }

  func getName(_ bodyData: SysexBodyData, index: Int) -> String?

  var isValidSize: (Int) -> Bool { get }

}
