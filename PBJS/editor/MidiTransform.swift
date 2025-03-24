
import PBAPI
import JavaScriptCore

extension MidiTransform: JsParsable {
  
  static let jsRules: [JsParseRule<Self>] = [
    .d([
      "type" : "singlePatch",
    ], {
      let throttle = try $0.xq("throttle") ?? 30
      let paramFn = try $0.fn("param")
      let patchFn = try $0.any("patch")
      
      let name: MidiTransform.Fn<SinglePatchTruss>.Name?
      if let nameFn = try? $0.any("name") {
        name = .init({ editor, bodyData, path, name in
          try SinglePatchTruss.makeMidiPairs(nameFn, bodyData, editor, [path, name])
        })
      }
      else {
        name = nil
      }

      return .single(throttle: throttle, .patch(coalesce: 2, param: .init({ editor, bodyData, path, parm, value in
        try SinglePatchTruss.makeMidiPairs(paramFn, bodyData, editor, [path.toJS(), parm?.toJS(), value])
      }), patch: .init({ editor, bodyData in
        try SinglePatchTruss.makeMidiPairs(patchFn, bodyData, editor, [])
      }), name: name))
    }),
    .d([
      "type" : "singleWholePatch",
    ], {
      let throttle = try $0.xq("throttle") ?? 30
      let patchFn = try $0.any("patch")
      
      return .single(throttle: throttle, .wholePatch(.init({ editor, bodyData in
        try SinglePatchTruss.makeMidiPairs(patchFn, bodyData, editor, [])
      })))
    }),
    .d([
      "type" : "multiDictPatch",
    ], {
      let throttle = try $0.xq("throttle") ?? 30
      let paramFn = try $0.fn("param")
      let patchFn = try $0.any("patch")
      let nameFn = try $0.any("name")

      return .multiDict(throttle: throttle, .patch(param: .init({ editor, bodyData, path, parm, value in
        return try MultiPatchTruss.makeMidiPairs(paramFn, bodyData, editor, [path.toJS(), parm?.toJS(), value])
      }), patch: .init({ editor, bodyData in
        return try MultiPatchTruss.makeMidiPairs(patchFn, bodyData, editor, [])
      }), name: .init({ editor, bodyData, path, name in
        return try MultiPatchTruss.makeMidiPairs(nameFn, bodyData, editor, [path, name])
      })))
    }),    
    .d([
      "type" : "singleBank",
    ], {
      let throttle = try $0.xq("throttle") ?? 30
      let bankFn = try $0.fn("bank")
      return .single(throttle: throttle, .bank({ editor, bodyData, location in
        try SinglePatchTruss.makeMidiPairs(bankFn, bodyData, editor, [location])
      }))
    }),
    .d([
      "type" : "wholeBank",
    ], {
      let throttle = try $0.xq("throttle") ?? 30
      if let fn = try? $0.any("single") {
        return .single(throttle: throttle, .wholeBank({ editor, bodyData in
          try SingleBankTruss.makeMidiPairs(fn, bodyData, editor, [])
        }))
      }
      else if let fn = try? $0.any("multi") {
        return .multi(throttle: throttle, .wholeBank({ editor, bodyData in
          try MultiBankTruss.makeMidiPairs(fn, bodyData, editor, [])
        }))
      }
      throw JSError.error(msg: "Midi Transform: wholeBank: must specify either 'single' or 'multi' property with transform function")
    }),
  ]

}
