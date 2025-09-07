
import PBAPI

extension SinglePatchTruss: JsBankParsable {
  
  public static let nuJsBankRules: [JsParseRule<SingleBankTruss>] = [
    .d([
      "singleBank" : SinglePatchTruss.self,
      "patchCount" : Int.self,
      "locationIndex" : Int.self,
      "createFile" : SingleBankTruss.Core.ToMidiFn.self,
      "initFile?" : String.self,
      "validSizes" : [Int].self,
      "includeFileDataCount" : Bool.self,
    ], {
      let patchTruss: Self = try $0.x("singleBank")
      let patchCount: Int = try $0.x("patchCount")
      
      let parseBody = try SingleBankTruss.sortAndParseBodyDataWithLocationIndex($0.x("locationIndex"), parseBodyData: patchTruss.core.parseBodyData, patchCount: patchCount)

      return try .init(patchTruss: patchTruss, patchCount: patchCount, initFile: $0.xq("initFile") ?? "", fileDataCount: nil, defaultName: nil, createFileData: $0.x("createFile"), parseBodyData: parseBody, validSizes: $0.x("validSizes"), includeFileDataCount: $0.x("includeFileDataCount"))
    }, "validSizes"),
    .d([
      "singleBank" : SinglePatchTruss.self,
      "patchCount" : Int.self,
      "locationIndex" : Int.self,
      "createFile" : SingleBankTruss.Core.ToMidiFn.self,
      "initFile?" : String.self,
      "validBundle?" : ValidBundle.self,
    ], {
      let patchTruss: Self = try $0.x("singleBank")
      let patchCount: Int = try $0.x("patchCount")
      
      let parseBody = try SingleBankTruss.sortAndParseBodyDataWithLocationIndex($0.x("locationIndex"), parseBodyData: patchTruss.core.parseBodyData, patchCount: patchCount)

      return try .init(patchTruss: patchTruss, patchCount: patchCount, initFile: $0.xq("initFile") ?? "", fileDataCount: nil, defaultName: nil, createFileData: $0.x("createFile"), parseBodyData: parseBody, validBundle: $0.xq("validBundle"))
    }, "bundle"),
    .d([
      "compactSingleBank" : SinglePatchTruss.self,
      "patchCount" : Int.self,
      "fileDataCount" : Int.self,
      "initFile?" : String.self,
      "createFile" : JsObj.self,
      "parseBody" : JsObj.self,
    ], {
      let patchTruss: Self = try $0.x("patchTruss")
      let patchCount: Int = try $0.x("patchCount")
      let fileDataCount: Int = try $0.x("fileDataCount")
      let initFile = (try $0.xq("initFile")) ?? ""
      
      let createFile = try $0.obj("createFile")
      let wrapperFn: Self.Core.ToMidiFn = try createFile.x("wrapper")
      let patchBodyTransform: ByteTransform = try createFile.x("patchBodyTransform")
      
      let createFileFn: SomeBankTruss<Self>.Core.ToMidiFn = .fn({ bodyData, e in
        let patchData: [UInt8] = try bodyData.flatMap {
          try patchBodyTransform.call($0, e)
        }
        return try wrapperFn.call(patchData, e)
      })
      
      let parseBody = try $0.obj("parseBody")
      let offset: Int = try parseBody.x("offset")
      let patchByteCount: Int = try parseBody.x("patchByteCount")
      let parseBodyTransform: ByteTransform = try parseBody.x("patchBodyTransform")

      let parseBodyFn: SomeBankTruss<Self>.Core.FromMidiFn = .fn({
        let compactData = SomeBankTruss<Self>.compactData(fileData: $0.flatMap { $0.bytes() }, offset: offset, patchByteCount: patchByteCount)
        let bodyData = try compactData.map {
          try parseBodyTransform.call($0, nil)
        }
        
        // TX81Z (maybe others?) have patchCount lower than the number of compactChunks that maybe be present in the passed in data, hence the line below
        return SingleBankTruss.BodyData(bodyData[0..<patchCount])
      })
      
      return .init(patchTruss: patchTruss, patchCount: patchCount, initFile: initFile, fileDataCount: fileDataCount, defaultName: nil, createFileData: createFileFn, parseBodyData: parseBodyFn)
    }, "compactSingleBank"),
  ]
  
  
//  static let jsBankRules: [JsParseRule<SingleBankTruss>] = [
//    .d([
//      "type" : "singleBank",
//      "patchTruss" : ".d",
//      "patchCount" : ".n",
//      "locationIndex" : ".n",
//      "validSizes" : ".a",
//      "includeFileDataCount" : ".b",
//    ], {
//      let patchTruss: Self = try $0.x("patchTruss")
//      let patchCount: Int = try $0.x("patchCount")
//      let createFile = try $0.obj("createFile").xform(SingleBankTruss.bankToMidiRules)
//      
//      let parseBody = try SingleBankTruss.sortAndParseBodyDataWithLocationIndex($0.x("locationIndex"), parseBodyData: patchTruss.core.parseBodyData, patchCount: patchCount)
//
//      return try .init(patchTruss: patchTruss, patchCount: patchCount, initFile: $0.xq("initFile") ?? "", fileDataCount: nil, defaultName: nil, createFileData: createFile, parseBodyData: parseBody, validSizes: $0.x("validSizes"), includeFileDataCount: $0.x("includeFileDataCount"))
//    }),
//    .d([
//      "type" : "singleBank",
//      "patchTruss" : ".d",
//      "patchCount" : ".n",
//      "locationIndex" : ".n",
//    ], {
//      let patchTruss: Self = try $0.x("patchTruss")
//      let patchCount: Int = try $0.x("patchCount")
//      let createFile = try $0.obj("createFile").xform(SingleBankTruss.bankToMidiRules)
//      
//      let parseBody = try SingleBankTruss.sortAndParseBodyDataWithLocationIndex($0.x("locationIndex"), parseBodyData: patchTruss.core.parseBodyData, patchCount: patchCount)
//
//      return try .init(patchTruss: patchTruss, patchCount: patchCount, initFile: $0.xq("initFile") ?? "", fileDataCount: nil, defaultName: nil, createFileData: createFile, parseBodyData: parseBody, validBundle: $0.xq("validBundle"))
//    }),
//    .d([
//      "type" : "compactSingleBank",
//      "patchTruss" : ".d",
//      "patchCount" : ".n",
//      "fileDataCount" : ".n",
//      "initFile" : ".s?",
//      "createFile" : ".d",
//      "parseBody" : ".d",
//    ], {
//      let patchTruss: Self = try $0.x("patchTruss")
//      let patchCount: Int = try $0.x("patchCount")
//      let fileDataCount: Int = try $0.x("fileDataCount")
//      let initFile = (try $0.xq("initFile")) ?? ""
//      
//      let createFile = try $0.obj("createFile")
//      let wrapperFn: Self.Core.ToMidiFn = try createFile.x("wrapper")
//      let patchBodyTransform: ByteTransform = try createFile.x("patchBodyTransform")
//      
//      let createFileFn: SomeBankTruss<Self>.Core.ToMidiFn = .fn({ bodyData, e in
//        let patchData: [UInt8] = try bodyData.flatMap {
//          try patchBodyTransform.call($0, e)
//        }
//        return try wrapperFn.call(patchData, e)
//      })
//      
//      let parseBody = try $0.obj("parseBody")
//      let offset: Int = try parseBody.x("offset")
//      let patchByteCount: Int = try parseBody.x("patchByteCount")
//      let parseBodyTransform: ByteTransform = try parseBody.x("patchBodyTransform")
//
//      let parseBodyFn: SomeBankTruss<Self>.Core.FromMidiFn = .fn({
//        let compactData = SomeBankTruss<Self>.compactData(fileData: $0.flatMap { $0.bytes() }, offset: offset, patchByteCount: patchByteCount)
//        let bodyData = try compactData.map {
//          try parseBodyTransform.call($0, nil)
//        }
//        
//        // TX81Z (maybe others?) have patchCount lower than the number of compactChunks that maybe be present in the passed in data, hence the line below
//        return SingleBankTruss.BodyData(bodyData[0..<patchCount])
//      })
//      
//      return .init(patchTruss: patchTruss, patchCount: patchCount, initFile: initFile, fileDataCount: fileDataCount, defaultName: nil, createFileData: createFileFn, parseBodyData: parseBodyFn)
//    }),
//  ]
}

//extension SingleBankTruss {
//  static let parseBodyRules: JsParseTransformSet<Core.FromMidiFn> = try! .init([
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
