
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
      let nameFn = try $0.any("name")

      return .single(throttle: throttle, .patch(coalesce: 2, param: { editor, bodyData, parm, value in
        try makeMidiPairs(paramFn, bodyData, editor, [parm.toJS(), value])
      }, patch: { editor, bodyData in
        try makeMidiPairs(patchFn, bodyData, editor, [])
      }, name: { editor, bodyData, path, name in
        try makeMidiPairs(nameFn, bodyData, editor, [path, name])
      }))
    }),
    ([
      "type" : "multiDictPatch",
    ], {
      let throttle = (try? $0.int("throttle")) ?? 30
      let paramFn = try $0.fn("param")
      let patchFn = try $0.any("patch")
      let nameFn = try $0.any("name")

      return .multiDict(throttle: throttle, .patch(param: { editor, bodyData, parm, value in
        return try makeMidiPairs(paramFn, bodyData, editor, [parm.toJS(), value])
      }, patch: { editor, bodyData in
        return try makeMidiPairs(patchFn, bodyData, editor, [])
      }, name: { editor, bodyData, path, name in
        return try makeMidiPairs(nameFn, bodyData, editor, [path, name])
      }))
    }),    ([
      "type" : "singleBank",
    ], {
      let throttle = (try? $0.int("throttle")) ?? 30
      let bankFn = try $0.fn("bank")
      return .single(throttle: throttle, .bank({ editor, bodyData, location in
        try makeMidiPairs(bankFn, bodyData, editor, [location])
      }))
    })
  ], "midiTransform")
  
  static func makeMidiPairs(_ fn: JSValue, _ bodyData: SinglePatchTruss.BodyData, _ editor: AnySynthEditor, _ vals: [Any]) throws -> [(MidiMessage, Int)] {
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
        let fn = try $0.atIndex(0).xform(SinglePatchTruss.toMidiRules)
        return (.sysex(try fn(bodyData, editor)), try $0.any(1).int())
      }
    }
  }

  static func makeMidiPairs(_ fn: JSValue, _ bodyData: MultiPatchTruss.BodyData, _ editor: AnySynthEditor, _ vals: [Any]) throws -> [(MidiMessage, Int)] {
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
        let fn = try $0.atIndex(0).xform(MultiPatchTruss.toMidiRules)
        return (.sysex(try fn(bodyData, editor)), try $0.any(1).int())
      }
    }
  }

}
