
//class JsBackupTruss : JsSysexTruss {
//  
//  let jsValue: JSValue
//  let backupTruss: BackupTruss
//  var truss: AnySysexTruss { backupTruss }
//  let trussMapContainers: [(SynthPath, JsSysexTruss)]
//
//
//  required init(_ jsValue: JSValue) throws {
//    self.jsValue = jsValue
//    
//    let localType = try Self.localType(jsValue)
//    let initFileName = try Self.initFileName(jsValue)
//    let fileDataCount = try Self.fileDataCount(jsValue)
//
//    guard let trussMapProp = jsValue.forProperty("trussMap") else {
//      throw JSError.error(msg: "trussMap missing")
//    }
//    self.trussMapContainers = try Js.sysexMap(mapProp: trussMapProp)
//    let trussMap = trussMapContainers.map { ($0.0, $0.1.truss) }
//    let trussDict = trussMap.dictionary { [$0.0 : $0.1] }
//
//    let createFileData: ([SynthPath:Any]) throws -> [UInt8] = { bodyData in
//      try bodyData.compactMap {
//        guard let truss = trussDict[$0.key] else { return nil }
//        return try truss.createSysexible(bodyData: $0.value, name: nil).fileData()
//      }.reduce([], +)
//    }
//    
//    let parseBodyData: ([UInt8]) throws -> [SynthPath:Any] = { fileData in
//      var patchData = [SynthPath:Data]()
//  
//      // each sysex msg is either a global patch or a patch from one of the banks
//      try SysexData(data: fileData.data()).forEach { [unowned jsValue] msg in
//        guard let path = try Self.path(jsValue: jsValue, fileData: msg.bytes()) else { return }
//        if patchData[path] == nil {
//          patchData[path] = Data()
//        }
//        patchData[path]?.append(msg)
//      }
//  
//      var bodyData = [SynthPath:Any]()
//      try patchData.forEach { (path, data) in
//        guard let truss = trussDict[path] else { return }
//        bodyData[path] = try truss.createSysexible(fileData: data.bytes(), name: nil).anyBodyData
//      }
//  
//      // FullPerfs need blank subpatches for preset parts
//      // so for any unfilled subpatches, DO NOT init them
//      return bodyData
//    }
//
//    let isValidSize: (Int) -> Bool = { _ in true }
//    let isValidFileData: ([UInt8]) -> Bool = { _ in true }
//    let isCompleteFetch: ([UInt8]) -> Bool = { _ in true }
//
//    self.backupTruss = BackupTruss(trussMap: trussMap, trussDict: trussDict, createFileData: createFileData, parseBodyData: parseBodyData, localType: localType, initFileName: initFileName, isValidSize: isValidSize, isValidFileData: isValidFileData, isCompleteFetch: isCompleteFetch)
//  }
//  
//  static func path(jsValue: JSValue, fileData: [UInt8]) throws -> SynthPath? {
//    guard let value = jsValue.invokeMethod("path", withArguments: [fileData]) else { return nil }
//    try handlePossibleException(jsValue)
//    return JsSynthPath.decode(value)
//  }
//
//    
//}
//
