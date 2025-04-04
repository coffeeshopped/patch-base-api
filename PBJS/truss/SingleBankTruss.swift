
import PBAPI

extension SinglePatchTruss: JsBankParsable {
  
  static let jsBankRules: [JsParseRule<SingleBankTruss>] = [
    .d([
      "type" : "singleBank",
      "patchTruss" : ".d",
      "patchCount" : ".n",
      "locationIndex" : ".n",
      "validSizes" : ".a",
      "includeFileDataCount" : ".b",
    ], {
      let patchTruss: Self = try $0.x("patchTruss")
      let patchCount: Int = try $0.x("patchCount")
      let createFile = try $0.obj("createFile").xform(SingleBankTruss.bankToMidiRules)
      
      let parseBody = try SingleBankTruss.sortAndParseBodyDataWithLocationIndex($0.x("locationIndex"), parseBodyData: patchTruss.parseBodyData, patchCount: patchCount)

      return try .init(patchTruss: patchTruss, patchCount: patchCount, initFile: $0.xq("initFile") ?? "", fileDataCount: nil, defaultName: nil, createFileData: createFile, parseBodyData: parseBody, validSizes: $0.x("validSizes"), includeFileDataCount: $0.x("includeFileDataCount"))
    }),
    .d([
      "type" : "singleBank",
      "patchTruss" : ".d",
      "patchCount" : ".n",
      "locationIndex" : ".n",
    ], {
      let patchTruss: Self = try $0.x("patchTruss")
      let patchCount: Int = try $0.x("patchCount")
      let createFile = try $0.obj("createFile").xform(SingleBankTruss.bankToMidiRules)
      
      let parseBody = try SingleBankTruss.sortAndParseBodyDataWithLocationIndex($0.x("locationIndex"), parseBodyData: patchTruss.parseBodyData, patchCount: patchCount)

      return try .init(patchTruss: patchTruss, patchCount: patchCount, initFile: $0.xq("initFile") ?? "", fileDataCount: nil, defaultName: nil, createFileData: createFile, parseBodyData: parseBody, validBundle: $0.xq("validBundle"))
    }),
    .d([
      "type" : "compactSingleBank",
      "patchTruss" : ".d",
      "patchCount" : ".n",
      "paddedPatchCount" : ".n?",
      "fileDataCount" : ".n",
      "compactTruss": ".d",
    ], {
      let patchTruss: SinglePatchTruss = try $0.x("patchTruss")
      let patchCount: Int = try $0.x("patchCount")
      let paddedPatchCount = (try $0.xq("paddedPatchCount")) ?? patchCount
      let initFile = (try $0.xq("initFile")) ?? ""
      let fileDataCount: Int = try $0.x("fileDataCount")
      let compactTruss: SinglePatchTruss = try $0.x("compactTruss")
      let compactByteCount = compactTruss.bodyDataCount

      let singleCreateFile: SinglePatchTruss.Core.ToMidiFn = try $0.x("createFile")
      let createFile: SingleBankTruss.Core.ToMidiFn = .fn({ bodyData, e in
        var patchData: [UInt8] = try bodyData.flatMap {
          try compactTruss.parse(otherData: $0, otherTruss: patchTruss)
        }
        let remaining = paddedPatchCount - patchCount
        patchData += [UInt8](repeating: 0, count: remaining * compactByteCount)

        return try singleCreateFile.call(patchData, e)
      })
      
      let offset: Int = try $0.x("parseBody")
      let parseBody: SomeBankTruss<Self>.Core.ParseBodyDataFn = {
        let compactData = SomeBankTruss<Self>.compactData(fileData: $0, offset: offset, patchByteCount: compactByteCount)
        let bodyData = try compactData.map {
          try patchTruss.parse(otherData: $0, otherTruss: compactTruss)
        }
        
        // TX81Z (maybe others?) have patchCount lower than the number of compactChunks that maybe be present in the passed in data, hence the line below
        return SingleBankTruss.BodyData(bodyData[0..<patchCount])
      }
      
      return .init(patchTruss: patchTruss, patchCount: patchCount, initFile: initFile, fileDataCount: fileDataCount, defaultName: nil, createFileData: createFile, parseBodyData: parseBody)
    }),
  ]
}

//extension SingleBankTruss {
//  static let parseBodyRules: JsParseTransformSet<Core.ParseBodyDataFn> = try! .init([
//    ([
//      "locationIndex" : ".n",
//      "parseBody" : ".x",
//      "patchCount" : ".n",
//    ], {
//      let parseBody = try $0.any("parseBody").xform(SinglePatchTruss.parseBodyRules)
//      return try sortAndParseBodyDataWithLocationIndex($0.x("locationIndex"), parseBodyData: parseBody, patchCount: $0.x("patchCount"))
//    }),
//  ], "singleBankTruss parseBody")
//}
