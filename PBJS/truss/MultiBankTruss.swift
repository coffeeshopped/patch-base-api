
import PBAPI

extension MultiPatchTruss : JsBankParsable {
  
  static let jsBankRules: [JsParseRule<MultiBankTruss>] = [
    .d([
      "type" : "compactMultiBank",
      "patchTruss" : ".d",
      "patchCount" : ".n",
      "fileDataCount" : ".n",
      "compactTrussMap": ".d",
    ], {
      let patchTruss: MultiPatchTruss = try $0.x("patchTruss")
      let patchCount: Int = try $0.x("patchCount")
      let initFile = (try $0.xq("initFile")) ?? ""
      let fileDataCount: Int = try $0.x("fileDataCount")
      let compactTrussMap: [(SynthPath, SinglePatchTruss)] = try $0.any("compactTrussMap").x()
      let compactByteCount = compactTrussMap.first?.1.bodyDataCount ?? 0

      let singleCreateFile: SinglePatchTruss.Core.ToMidiFn = try $0.x("createFile")
      let createFile: MultiBankTruss.Core.ToMidiFn = .fn({ bodyData, e in
        let patchData: [UInt8] = try bodyData.flatMap { d in
          var compactData = [UInt8](repeating: 0, count: compactByteCount)
          try compactTrussMap.forEach {
            guard let bodyData = d[$0.0] else { return }
            let truss = patchTruss.trussDict[$0.0]! // TODO: needs to throw
            try truss.transform(bodyData, into: &compactData, using: $0.1)
          }
          return compactData
        }

        return try singleCreateFile.call(patchData, e)
      })
      
      let offset: Int = try $0.x("parseBody")
      let parseBody: MultiBankTruss.Core.FromMidiFn = .fn({
        let chunks = MultiBankTruss.compactData(fileData: $0.flatMap { $0.bytes() }, offset: offset, patchByteCount: compactByteCount)
        return try chunks.map { compactBytes in
          try compactTrussMap.dict {
            let truss = patchTruss.trussDict[$0.0]! // TODO: needs to throw
            return [$0.0 : try truss.parse(otherData: compactBytes, otherTruss: $0.1)]
          }
        }
      })
      
      return .init(patchTruss: patchTruss, patchCount: patchCount, initFile: initFile, fileDataCount: fileDataCount, defaultName: nil, createFileData: createFile, parseBodyData: parseBody)
    }),
  ]
  
}

//extension MultiBankTruss {
//  static let parseBodyRules: JsParseTransformSet<Core.FromMidiFn> = try! .init([
//    ([
//      "locationIndex" : ".n",
//      "parseBody" : ".x",
//      "patchCount" : ".n",
//    ], {
//      let parseBody = try $0.any("parseBody").xform(SinglePatchTruss.parseBodyRules)
//      let patchCount = try $0.int("patchCount")
//      let locationIndex = try $0.int("locationIndex")
//      return sortAndParseBodyDataWithLocationIndex(locationIndex, parseBodyData: parseBody, patchCount: patchCount)
//    }),
//  ], "singleBankTruss parseBody")
//}
//
