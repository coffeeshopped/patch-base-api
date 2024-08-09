
import PBAPI
import JavaScriptCore

extension MidiTransform: JsParsable {
  
  static let jsParsers: JsParseTransformSet<Self> = try! .init([
    ([
      "type" : "singlePatch",
    ], {
      let throttle = (try? $0.int("throttle")) ?? 30
      let paramFn = try $0.fn("param")
      let patchFn = try $0.any("patch")
      let nameFn = try $0.fn("name")

      return .single(throttle: throttle, try? $0.xform("editorVal"), .patch(coalesce: 2, param: { editorVal, bodyData, parm, value in
        try makeMidiPairs(paramFn, bodyData, [editorVal], [parm.toJS(), value])
      }, patch: { editorVal, bodyData in
        try makeMidiPairs(patchFn, bodyData, [editorVal], [])
      }, name: { editorVal, bodyData, path, name in
        try makeMidiPairs(nameFn, bodyData, [editorVal], [path, name])
      }))
    }),
    ([
      "type" : "multiDictPatch",
    ], {
      let throttle = (try? $0.int("throttle")) ?? 30
      let editorVals: [EditorValueTransform] = (try? $0.xform("editorVal")) ?? []
      let paramFn = try $0.fn("param")
      let patchFn = try $0.any("patch")
      let nameFn = try $0.fn("name")

      return .multiDict(throttle: throttle, editorVals, .patch(param: { editorVal, bodyData, parm, value in
        let e = editorVals.map { editorVal[$0]! }
        return try makeMidiPairs(paramFn, bodyData, e, [parm.toJS(), value])
      }, patch: { editorVal, bodyData in
        let e = editorVals.map { editorVal[$0]! }
        return try makeMidiPairs(patchFn, bodyData, e, [])
      }, name: { editorVal, bodyData, path, name in
        let e = editorVals.map { editorVal[$0]! }
        return try makeMidiPairs(nameFn, bodyData, e, [path, name])
      }))
    }),    ([
      "type" : "singleBank",
    ], {
      let throttle = (try? $0.int("throttle")) ?? 30
      let bankFn = try $0.fn("bank")
      return .single(throttle: throttle, try? $0.xform("editorVal"), .bank({ editorVal, bodyData, location in
        try makeMidiPairs(bankFn, bodyData, [editorVal], [location])
      }))
    })
  ], "midiTransform")
  
  static func makeMidiPairs(_ fn: JSValue, _ bodyData: SinglePatchTruss.BodyData, _ editorVals: [Any], _ vals: [Any]) throws -> [(MidiMessage, Int)] {
    // fn can be a JS function
    // or it can be something that should be parsed as a createFile...
    let mapVal = fn.isFn ? try fn.call(vals) : fn
    return try mapVal!.map {
      if let msg = try? $0.arr(0).xform(MidiMessage.jsParsers) {
        return (msg, try $0.any(1).int())
      }
      else {
        // if what's returned doesn't match a midi msg rule, then treat it like a createFileFn
        // TODO: here is where some caching needs to happen. Perhaps that caching
        // could be implemented in the JsParseTransformSet struct.
        let fn = try $0.atIndex(0).xform(SinglePatchTruss.createFileRules)
        return (.sysex(try fn(bodyData, editorVals)), try $0.any(1).int())
      }
    }
  }

  static func makeMidiPairs(_ fn: JSValue, _ bodyData: MultiPatchTruss.BodyData, _ editorVals: [Any], _ vals: [Any]) throws -> [(MidiMessage, Int)] {
    // fn can be a JS function
    // or it can be something that should be parsed as a createFile...
    let mapVal = fn.isFn ? try fn.call(vals) : fn
    return try mapVal!.map {
      if let msg = try? $0.arr(0).xform(MidiMessage.jsParsers) {
        return (msg, try $0.any(1).int())
      }
      else {
        // if what's returned doesn't match a midi msg rule, then treat it like a createFileFn
        // TODO: here is where some caching needs to happen. Perhaps that caching
        // could be implemented in the JsParseTransformSet struct.
        let fn = try $0.atIndex(0).xform(MultiPatchTruss.createFileRules)
        return (.sysex(try fn(bodyData, editorVals)), try $0.any(1).int())
      }
    }
  }

}
