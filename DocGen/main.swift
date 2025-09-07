//
//  main.swift
//  DocGen
//
//  Created by Chadwick Wood on 9/6/25.
//

import Foundation
import PBAPI
import PBJS

let docPath = "/Code/patch-base-api/PBJS/docs/api-rules/"

let jsTypes: [JsDocable.Type] = [
  Parm.self,
  IsoFF.self,
  IsoFS.self,
  PackIso.self,
  BasicModuleTruss.self,
  BasicEditorTruss.self,
]

let jsonEncoder = JSONEncoder()

jsTypes.forEach {
  // create a file for overwrite named after the type
  let url = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("\(docPath)\($0.jsName()).json")
  var matchDict = [String:String]()
  $0.matchArr.forEach {
    let hash = $0.string().hash
    matchDict["r\(hash)"] = $0.string()
  }
  let json = try! jsonEncoder.encode(matchDict)
  try! json.write(to: url)
}

