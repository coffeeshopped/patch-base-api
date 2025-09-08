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
  SynthPath.self,
  SynthPathMap.self,
  Parm.self,
  IsoFF.self,
  IsoFS.self,
  PackIso.self,
  PackIso.Blitter.self,
  BasicModuleTruss.self,
  BasicEditorTruss.self,
  MidiChannelTransform.self,
  MidiTransform.self,
  FetchTransform.self,
  EditorValueTransform.self,
  ParamOutTransform.self,
  MemSlot.Transform.self,
  RxMidi.FetchCommand.self,
  MidiMessage.self,
  RolandEditorTrussWerk.MapItem.self,
  RolandAddress.self,
  RolandSinglePatchTrussWerk.self,
  RolandMultiPatchTrussWerk.self,
  RolandMultiBankTrussWerk.self,
  RolandOffsetAddressIso.self,
  RolandMultiPatchTrussWerk.MapItem.self,
  PBBezier.PathCommand.self,
  DXAlgorithm.self,
  SinglePatchTruss.self,
  NamePackIso.self,
  SingleBankTruss.self,
  JSONPatchTruss.self,
  MultiPatchTruss.self,
  MultiBankTruss.self,
  SinglePatchTruss.Core.ToMidiFn.self,
  MultiPatchTruss.Core.ToMidiFn.self,
  SinglePatchTruss.Core.FromMidiFn.self,
  ByteTransform.self,
  ValidBundle.self,
  PatchController.self,
  PatchController.Prefix.self,
  PatchController.Builder.self,
  PatchController.Effect.self,
  PatchController.ConfigParam.self,
  PatchController.AttrChange.self,
  PatchController.PanelItem.self,
  PatchController.Display.self,
  PatchController.DisplayMap.self,
  PatchController.Constraint.self,
  PatchController.PageSetup.self,
  ClosedRange<Int>.self,
]

let jsonEncoder = JSONEncoder()

jsTypes.forEach {
  // create a file for overwrite named after the type
  let url = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("\(docPath)\($0.jsName()).json")
  var matchDict: [String:[String:String]] = [
    "single" : [:],
    "array" : [:]
  ]
  $0.docInfo["single"]?.forEach {
    matchDict["single"]?[$1] = $0.string(links: true)
  }
  $0.docInfo["array"]?.forEach {
    matchDict["array"]?[$1] = $0.string(links: true)
  }
  let json = try! jsonEncoder.encode(matchDict)
  try! json.write(to: url)
}

