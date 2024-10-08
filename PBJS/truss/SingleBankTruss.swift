
import PBAPI

extension SinglePatchTruss: JsBankParsable {
  
  static let jsBankParsers: JsParseTransformSet<SingleBankTruss> = try! .init([
    ([
      "type" : "singleBank",
      "patchTruss" : ".d",
      "patchCount" : ".n",
      "validSizes" : ".a",
      "includeFileDataCount" : ".b",
    ], {
      let patchTruss = try $0.obj("patchTruss").xform(jsParsers)
      let initFile = (try $0.xq("initFile")) ?? ""
      let validSizes = try $0.arr("validSizes").arrInt()
      let includeFileDataCount: Bool = try $0.x("includeFileDataCount")
      let createFile = try $0.obj("createFile").xform(SingleBankTruss.toMidiRules)
      let parseBody = try $0.obj("parseBody").xform(SingleBankTruss.parseBodyRules)
      return try .init(patchTruss: patchTruss, patchCount: $0.x("patchCount"), initFile: initFile, fileDataCount: nil, defaultName: nil, createFileData: createFile, parseBodyData: parseBody)
    }),
    ([
      "type" : "compactSingleBank",
      "patchTruss" : ".d",
      "patchCount" : ".n",
      "paddedPatchCount" : ".n?",
      "fileDataCount" : ".n",
      "compactTruss": ".d",
    ], {
      let patchTruss: SinglePatchTruss = try $0.obj("patchTruss").x()
      let patchCount: Int = try $0.x("patchCount")
      let paddedPatchCount = (try $0.xq("paddedPatchCount")) ?? patchCount
      let initFile = (try $0.xq("initFile")) ?? ""
      let fileDataCount: Int = try $0.x("fileDataCount")
      let compactTruss: SinglePatchTruss = try $0.x("compactTruss")
      let compactByteCount = compactTruss.bodyDataCount

      let singleCreateFile: SinglePatchTruss.Core.ToMidiFn = try $0.x("createFile")
      let createFile: SingleBankTruss.Core.ToMidiFn = .fn({ bodyData, e in
        var patchData: [UInt8] = bodyData.flatMap {
          compactTruss.parse(otherData: $0, otherTruss: patchTruss)
        }
        let remaining = paddedPatchCount - patchCount
        patchData += [UInt8](repeating: 0, count: remaining * compactByteCount)

        return try singleCreateFile.call(patchData, e)
      })
      
      let offset: Int = try $0.x("parseBody")
      let parseBody: SomeBankTruss<Self>.Core.ParseBodyDataFn = {
        let compactData = SomeBankTruss<Self>.compactData(fileData: $0, offset: offset, patchByteCount: compactByteCount)
        let bodyData = compactData.map {
          patchTruss.parse(otherData: $0, otherTruss: compactTruss)
        }
        
        // TX81Z (maybe others?) have patchCount lower than the number of compactChunks that maybe be present in the passed in data, hence the line below
        return SingleBankTruss.BodyData(bodyData[0..<patchCount])
      }
      
      return .init(patchTruss: patchTruss, patchCount: patchCount, initFile: initFile, fileDataCount: fileDataCount, defaultName: nil, createFileData: createFile, parseBodyData: parseBody)
    }),
  ], "singleBankTruss")
}

extension SinglePatchTruss : JsBankToMidiParsable {
  
  static let bankToMidiRules: JsParseTransformSet<SomeBankTruss<Self>.Core.ToMidiFn> = try! .init([
    ([
      "locationMap" : ".f",
    ], {
      let locationMap = try $0.fn("locationMap")
      let fn: SomeBankTruss<Self>.Core.ToMidiFn =  SomeBankTruss<Self>.createFileDataWithLocationMap { bodyData, location in
        try locationMap.call([bodyData, location]).x()
      }
      return fn
    }),
  ], "singleBankTruss createFile")
  
}

extension SingleBankTruss {
  static let parseBodyRules: JsParseTransformSet<Core.ParseBodyDataFn> = try! .init([
    ([
      "locationIndex" : ".n",
      "parseBody" : ".x",
      "patchCount" : ".n",
    ], {
      let parseBody = try $0.any("parseBody").xform(SinglePatchTruss.parseBodyRules)
      return try sortAndParseBodyDataWithLocationIndex($0.x("locationIndex"), parseBodyData: parseBody, patchCount: $0.x("patchCount"))
    }),
  ], "singleBankTruss parseBody")
}
