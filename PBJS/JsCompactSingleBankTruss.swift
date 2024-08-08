
//
//class JsCompactSingleBankTruss : JsSysexTruss {
//  
//  let jsValue: JSValue
//  let singleBankTruss: SingleBankTruss
//  var truss: AnySysexTruss { singleBankTruss }
//
//  let singlePatchTrussValue: JSValue
//  let singlePatchTruss: SinglePatchTruss
//  
//  required init(_ jsValue: JSValue) throws {
//    self.jsValue = jsValue
//    
//    let localType = try Self.localType(jsValue)
//    let initFileName = try Self.initFileName(jsValue)
//    let fileDataCount = try Self.fileDataCount(jsValue)
//    let patchCount = try Self.getInt(jsValue, "patchCount", "patchCount property not found")
//    guard let trussValue = jsValue.forProperty("PatchType") else {
//      throw JSError.error(msg: "PatchType missing")
//    }
//    // if this isn't here, the JSValue seems to get deallocated not sure why
//    self.singlePatchTrussValue = trussValue
//
//    let singlePatchTruss = try JsSinglePatchTruss(trussValue).singlePatchTruss
//    self.singlePatchTruss = singlePatchTruss
//
//    let params = try JsSinglePatchTruss.parseParams(jsValue: jsValue, property: "compactParamOptions")
//    let compactByteCount = try Self.getInt(jsValue, "compactByteCount", "compactByteCount property not found")
//    let compactNameByteRange = JsSinglePatchTruss.parseNameByteRange(jsValue: jsValue, property: "compactNameByteRange")
//
//    let createFileData: (SingleBankTruss.BodyData) throws -> [UInt8] = { [unowned jsValue] in
//      // incoming data is byte arrays, not compacted
//      let compactByteArrays: [[UInt8]] = try $0.map {
//        let patchBody = try singlePatchTruss.parseBodyData($0)
//        var compactBody = [UInt8](repeating: 0, count: compactByteCount)
//        // extract each param value (and name out of the byte) array
//        // then pack based on compactParams to new array
//        params.forEach { (path, param) in
//          if let v = singlePatchTruss.getValue(patchBody, path: path) {
//            let byte = SinglePatchTruss.defaultPackedByte(value: v, forParam: param, byte: compactBody[param.byte])
//            compactBody[param.byte] = byte
//          }
//        }
//        
//        if let compactNameByteRange = compactNameByteRange,
//           let name = singlePatchTruss.getName($0) {
//          let nameBytes = name.bytes(forCount: compactNameByteRange.count)
//          compactBody.replaceSubrange(compactNameByteRange, with: nameBytes)
//        }
//        
//        return compactBody
//      }
//      
//      // then call fileData with the compact arrays
//      return try Self.fileData(jsValue: jsValue, compactByteArrays)
//    }
//    
//    let parseBodyData: ([UInt8]) throws -> SingleBankTruss.BodyData = { [unowned jsValue] in
//      return try Self.byteArrays(jsValue: jsValue, fileData: $0).map { compactBody in
//        var patchBody = try singlePatchTruss.parseBodyData([])
//        params.forEach { (path, param) in
//          guard let v = SinglePatchTruss.defaultUnpack(byte: param.byte, bits: param.bits, forBytes: compactBody) else { return }
//          singlePatchTruss.setValue(&patchBody, path: path, v)
//        }
//        
//        if let compactNameByteRange = compactNameByteRange {
//          let name = SinglePatchTruss.name(forRange: compactNameByteRange, bytes: compactBody)
//          singlePatchTruss.setName(&patchBody, name)
//        }
//
//        return patchBody
//      }
//    }
//    
//    let isValidSize: (Int) -> Bool = { _ in true }
//    let isValidFileData: ([UInt8]) -> Bool = { _ in true }
//    let isCompleteFetch: ([UInt8]) -> Bool = { _ in true }
//
//    self.singleBankTruss = SingleBankTruss(patchTruss: self.singlePatchTruss, patchCount: patchCount, createFileData: createFileData, parseBodyData: parseBodyData, localType: localType, initFileName: initFileName, fileDataCount: fileDataCount, maxNameCount: 32, isValidSize: isValidSize, isValidFileData: isValidFileData, isCompleteFetch: isCompleteFetch)
//    
//  }
//  
//  static func fileData(jsValue: JSValue, _ byteArrays: [[UInt8]]) throws -> [UInt8] {
//    (try jsMethod(jsValue: jsValue, "fileData", [byteArrays])?.toArray() as? [Int32])?.map { UInt8($0) } ?? []
//  }
//  
//  static func byteArrays(jsValue: JSValue, fileData: [UInt8]) throws -> SingleBankTruss.BodyData {
//    let b = (try jsMethod(jsValue: jsValue, "compactByteArrays", [fileData])?.toArray() as? [[Int32]])?.map {
//      $0.map { UInt8($0) }
//    } ?? [[]]
//    return b
//  }
//  
//    
//}
//
//
