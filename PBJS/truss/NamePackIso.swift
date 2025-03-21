//
//  NamePackIso.swift
//  PBJS
//
//  Created by Chadwick Wood on 9/16/24.
//

import PBAPI

extension NamePackIso : JsParsable {
  
  static var jsRules: [JsParseRule<NamePackIso>] = [
    .a([".n", ".n"], {
      let start: Int = try $0.x(0)
      let end: Int = try $0.x(1)
      return .basic(start..<end)
    }),
    .d([
      "type" : "filtered",
      "range" : ".a",
      "toBytes" : ".a",
      "toString" : ".a",
    ], {
      let rangeArr = try $0.arr("range")
      let range: CountableRange<Int> = (try rangeArr.x(0))..<(try rangeArr.x(1))
      let byteFilters = try $0.arr("toBytes").xformArr(nameFilterRules)
      let stringFilters = try $0.arr("toString").xformArr(nameFilterRules)
      // TODO: allow for a pad value other than 32 (for alt encodings)
      return NamePackIso.filtered(range) {
        let bytes = $0.compactMap { $0.asciiValue } // convert to uint8's
        return try bytes.compactMap { byte in
          try byteFilters.reduce(Optional(byte)) { partialResult, filter in
            guard let partialResult = partialResult else { return nil }
            return try filter(partialResult)
          }
        }.paddedTo(length: range.count, value: 32)
      } toName: {
        let bytes = try $0.compactMap { byte in
          try stringFilters.reduce(Optional(byte)) { partialResult, filter in
            guard let partialResult = partialResult else { return nil }
            return try filter(partialResult)
          }
        }
        return String(bytes: bytes, encoding: .ascii)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
      }

    }),
  ]
  
  static let nameFilterRules: [JsParseRule<(UInt8) throws -> UInt8?>] = [
    .s("upper", { _ in
      { Character(Unicode.Scalar($0)).uppercased().first?.asciiValue }
    }),
    .s("clean", { _ in
      { (32...126).contains($0) ? $0 : nil }
    }),
    .s(".f", { fn in
      try fn.checkFn()
      return {
        let result = try fn.call([$0], exportOrigin: nil)!
        if result.isNumber {
          return result.toNumber().uint8Value
        }
        else if result.isNull {
          return nil
        }
        throw JSError.error(msg: "Name byte filter returned an unexpected type.")
      }
    })
  ]
}
