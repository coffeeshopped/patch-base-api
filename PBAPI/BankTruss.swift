
public protocol BankTruss : SysexTruss {
  var anyPatchTruss: any PatchTruss { get }
  var patchCount: Int { get }

//  func createBank(fileData: [UInt8]?, name: String?) throws -> AnySysexPatchBank

  func getName(_ bodyData: SysexBodyData, index: Int) -> String?

  var isValidSize: (Int) -> Bool { get }

}

public extension BankTruss {
  
//  func patchArray(fromData data: Data, namePrefix: String = "Patch", locationBlock: ([UInt8]) -> Int) -> [SysexPatch] {
//    let sysex = SysexData(data: data)
//    // patches can be multiple sysex messages
//    // so first put together the data in chunks, then make patches from it
//    var sysexDict = [Int:[UInt8]]()
//    for msg in sysex {
//      let d = [UInt8](msg)
//      // some banks will have other sysex in them. skip that stuff
//      // but ONLY for single sysex patches! multi sysex patches wouldn't pass this test
//      if patchTruss is SinglePatchTruss {
//        guard patchTruss.isValid(sysex: d) else { continue }
//      }
//
//      let location = locationBlock(d)
//      if sysexDict[location] == nil {
//        sysexDict[location] = d
//      }
//      else {
//        sysexDict[location]?.append(contentsOf: d)
//      }
//    }
//    return (0..<patchCount).map {
//      guard let d = sysexDict[$0] else { return try! patchTruss.createPatch() }
//      var p = try! patchTruss.createPatch(fileData: d)
//      // for patches that don't store names
//      if p.name == "" {
//        p.name = "\(namePrefix) \($0+1)"
//      }
//      return p
//    }
//  }
  
}
