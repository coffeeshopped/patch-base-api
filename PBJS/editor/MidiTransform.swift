
import PBAPI
import JavaScriptCore

extension MidiTransform: JsParsable {
  
  public static let jsRules: [JsParseRule<Self>] = [
    .d([
      "singlePatch" : Fn<SinglePatchTruss>.Whole.self,
      "throttle?" : Int.self,
      "param?" : Fn<SinglePatchTruss>.Param.self,
      "name?" : Fn<SinglePatchTruss>.Name.self,
    ], {
      try .single(throttle: $0.xq("throttle"), .patch(coalesce: 2, param: $0.xq("param"), patch: $0.x("singlePatch"), name: $0.xq("name")))
    }, "singlePatch"),
    .d([
      "multiPatch" : Fn<MultiPatchTruss>.Whole.self,
      "throttle?" : Int.self,
      "param?" : Fn<MultiPatchTruss>.Param.self,
      "name?" : Fn<MultiPatchTruss>.Name.self,
    ], {
      try .multi(throttle: $0.xq("throttle"), .patch(param: $0.xq("param"), patch: $0.x("multiPatch"), name: $0.x("name")))
    }, "multiPatch"),
    .d([
      "singleBank" : Fn<SinglePatchTruss>.BankPatch.self,
      "throttle?" : Int.self,
    ], {
      try .single(throttle: $0.xq("throttle"), .bank($0.x("singleBank")))
    }, "singleBank"),
    .d([
      "compactSingleBank" : JsObj.self,
      "waitInterval?" : Int.self,
    ], {
      // assume a bank truss has been passed, and make a wholeBank out of it.
      let truss: SingleBankTruss = try $0.x()
      let fn = truss.core.createFileData
      let waitInterval: Int = try $0.xq("waitInterval") ?? 10
      return .single(throttle: nil, .wholeBank(.init({ editor, bodyData in
        try fn.call(bodyData, editor).map { ($0, waitInterval) }
      })))
    }, "compactSingleBank"),
    .d([
      "compactMultiBank" : JsObj.self,
      "waitInterval?" : Int.self,
    ], {
      // assume a bank truss has been passed, and make a wholeBank out of it.
      let truss: MultiBankTruss = try $0.x()
      let fn = truss.core.createFileData
      let waitInterval: Int = try $0.xq("waitInterval") ?? 10
      return .multi(throttle: nil, .wholeBank(.init({ editor, bodyData in
        try fn.call(bodyData, editor).map { ($0, waitInterval) }
      })))
    }, "compactMultiBank"),
  ]

}

extension MidiTransform.Fn.Param : JsParsable {
  
  public static var jsRules: [JsParseRule<Self>] {
    return [
      .t(JsFn.self, { fn in
        return .init { editor, bodyData, path, parm, value in
          let mapVal = try fn.call([path.toJS(), parm?.toJS(), value], exportOrigin: nil)
          return try mapVal!.flatMap {
            if let msg: MidiMessage = try? $0.x(0) {
              return [(msg, try $0.x(1) as Int)]
            }
            else {
              // if what's returned doesn't match a midi msg rule, then treat it like a createFileFn
              let fn: Truss.Core.ToMidiFn = try $0.x(0)
              let interval: Int = try $0.x(1)
              return try fn.call(bodyData, editor).map { ($0, interval) }
            }
          }
        }
      })
    ]
  }
  
}

extension MidiTransform.Fn.Whole : JsParsable {
  
  public static var jsRules: [JsParseRule<Self>] {
    return [
      // treat an array as a bunch of midiFn, waitTime pairs.
      .t([JsObj].self, {
        let fnPairs: [(Truss.Core.ToMidiFn, Int)]
        do {
          // try parsing as pairs
          fnPairs = try $0.x()
        }
        catch {
          // if that parse fails, see if it's just a single ToMidiFn
          let firstErr = error
          do {
            fnPairs = [(try $0.x(), 0)]
          }
          catch {
            // if *that* fails, throw the first error (from the pair parsing).
            throw firstErr
          }
        }
        return .init { editor, bodyData in
          try fnPairs.flatMap { fn, n in
            try fn.call(bodyData, editor).map { ($0, n) }
          }
        }
      })
    ]
  }

}

extension MidiTransform.Fn.Name: JsParsable {
  
  public static var jsRules: [JsParseRule<Self>] {
    return [
      // treat an array as a bunch of midiFn, waitTime pairs.
      .t([JsObj].self, {
        let fnPairs: [(Truss.Core.ToMidiFn, Int)]
        do {
          // try parsing as pairs
          fnPairs = try $0.x()
        }
        catch {
          // if that parse fails, see if it's just a single ToMidiFn
          let firstErr = error
          do {
            fnPairs = [(try $0.x(), 0)]
          }
          catch {
            // if *that* fails, throw the first error (from the pair parsing).
            throw firstErr
          }
        }
        return .init { editor, bodyData, path, name in
          try fnPairs.flatMap { fn, n in
            try fn.call(bodyData, editor).map { ($0, n) }
          }
        }
      }),
    ]
  }
    
}

extension MidiTransform.Fn.BankPatch : JsParsable {
  
  public static var jsRules: [JsParseRule<Self>] {
    return [
      .t(JsFn.self, { fn in
        return .init { editor, bodyData, location in
          let mapVal = try fn.call([location], exportOrigin: nil)
          return try mapVal!.flatMap {
            if let msg: MidiMessage = try? $0.x(0) {
              return [(msg, try $0.x(1) as Int)]
            }
            else {
              // if what's returned doesn't match a midi msg rule, then treat it like a createFileFn
              let fn: Truss.Core.ToMidiFn = try $0.x(0)
              let interval: Int = try $0.x(1)
              return try fn.call(bodyData, editor).map { ($0, interval) }
            }
          }
        }
      })
    ]
  }
  
}

extension MidiTransform.Fn.WholeBank : JsParsable {
  
  public static var jsRules: [JsParseRule<Self>] {
    return [
      // treat an array as a bunch of midiFn, waitTime pairs.
      .t([JsObj].self, {
        let fnPairs: [(SomeBankTruss<Truss>.Core.ToMidiFn, Int)] = try $0.x()
        return .init { editor, bodyData in
          try fnPairs.flatMap { fn, n in
            try fn.call(bodyData, editor).map { ($0, n) }
          }
        }
      }),
    ]
  }

}
