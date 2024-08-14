
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
      let patchCount = try $0.int("patchCount")
      let initFile = (try? $0.str("initFile")) ?? ""
      let validSizes = try $0.arr("validSizes").arrInt()
      let includeFileDataCount = try $0.bool("includeFileDataCount")
      let createFile = try $0.obj("createFile").xform(SingleBankTruss.toMidiRules)
      let parseBody = try $0.obj("parseBody").xform(SingleBankTruss.parseBodyRules)
      return .init(patchTruss: patchTruss, patchCount: patchCount, initFile: initFile, fileDataCount: nil, defaultName: nil, createFileData: createFile, parseBodyData: parseBody)
    }),
    ([
      "type" : "compactSingleBank",
      "patchTruss" : ".d",
      "patchCount" : ".n",
      "paddedPatchCount" : ".n?",
      "fileDataCount" : ".n",
      "compactTruss": ".d",
    ], {
      let patchTruss: SinglePatchTruss = try $0.obj("patchTruss").xform()
      let patchCount = try $0.int("patchCount")
      let paddedPatchCount = (try? $0.int("paddedPatchCount")) ?? patchCount
      let initFile = (try? $0.str("initFile")) ?? ""
      let fileDataCount = try $0.int("fileDataCount")
      let compactTruss: SinglePatchTruss = try $0.xform("compactTruss")
      let compactByteCount = compactTruss.bodyDataCount

      let singleCreateFile = try $0.any("createFile").xform(toMidiRules)
      let createFile: SingleBankTruss.Core.ToMidiFn = { bodyData, e in
        var patchData: [UInt8] = bodyData.flatMap {
          compactTruss.parse(otherData: $0, otherTruss: patchTruss)
        }
        let remaining = paddedPatchCount - patchCount
        patchData += [UInt8](repeating: 0, count: remaining * compactByteCount)

        return try singleCreateFile(patchData, e)
      }
      
      let offset = try $0.int("parseBody")
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
        try locationMap.call([bodyData, location]).arrByte()
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
      let patchCount = try $0.int("patchCount")
      let locationIndex = try $0.int("locationIndex")
      return sortAndParseBodyDataWithLocationIndex(locationIndex, parseBodyData: parseBody, patchCount: patchCount)
    }),
  ], "singleBankTruss parseBody")
}
