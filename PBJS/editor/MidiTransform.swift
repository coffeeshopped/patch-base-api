
import PBAPI
import JavaScriptCore

extension MidiTransform: JsParsable {
  
  static let jsRules: [JsParseRule<Self>] = [
    .d([
      "type" : "singlePatch",
    ], {
      try .single(throttle: $0.xq("throttle") ?? 30, .patch(coalesce: 2, param: $0.x("param"), patch: $0.x("patch"), name: $0.xq("name")))
    }),
    .d([
      "type" : "singleWholePatch",
    ], {
      try .single(throttle: $0.xq("throttle") ?? 30, .wholePatch($0.x("patch")))
    }),
    .d([
      "type" : "multiDictPatch",
    ], {
      try .multiDict(throttle: $0.xq("throttle") ?? 30, .patch(param: $0.x("param"), patch: $0.x("patch"), name: $0.x("name")))
    }),
    .d([
      "type" : "singleBank",
    ], {
      try .single(throttle: $0.xq("throttle") ?? 30, .bank($0.x("bank")))
    }),
    .d([
      "type" : "wholeBank",
      "single" : ".x",
    ], {
      try .single(throttle: $0.xq("throttle") ?? 30, .wholeBank($0.x("single")))
    }),
    .d([
      "type" : "wholeBank",
      "multi" : ".x",
    ], {
      try .multi(throttle: $0.xq("throttle") ?? 30, .wholeBank($0.x("multi")))
    }),
  ]

}

extension MidiTransform.Fn.Param : JsParsable {
  static var jsRules: [JsParseRule<Self>] {
    return [
      .s(".f", { fn in
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
  
  static var jsRules: [JsParseRule<Self>] {
    return [
      // treat an array as a bunch of midiFn, waitTime pairs.
      .s(".a", {
        let fnPairs: [(Truss.Core.ToMidiFn, Int)] = try $0.x()
        return .init { editor, bodyData in
          try fnPairs.flatMap { fn, n in
            try fn.call(bodyData, editor).map { ($0, n) }
          }
        }
      }),
    ]
  }

}

extension MidiTransform.Fn.Name: JsParsable {
  
  static var jsRules: [JsParseRule<Self>] {
    return [
      // treat an array as a bunch of midiFn, waitTime pairs.
      .s(".a", {
        let fnPairs: [(Truss.Core.ToMidiFn, Int)] = try $0.x()
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
  static var jsRules: [JsParseRule<Self>] {
    return [
      .s(".f", { fn in
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
  
  static var jsRules: [JsParseRule<Self>] {
    return [
      // treat an array as a bunch of midiFn, waitTime pairs.
      .s(".a", {
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
