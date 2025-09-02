
import PBAPI
import JavaScriptCore

extension PatchController.Constraint: JsParsable {
  
  static let nuJsRules: [NuJsParseRule<Self>] = [
    .d([
      "row": [Item].self,
      "opts?": [PBLayoutConstraint.FormatOption].self,
    ], {
      try .row($0.x("row"), opts: $0.xq("opts") ?? [.alignAllTop, .alignAllBottom], spacing: nil)
    }),
    .d([
      "rowPart": [Item].self,
      "opts?": [PBLayoutConstraint.FormatOption].self,
    ], {
      try .rowPart($0.x("rowPart"), opts: $0.xq("opts") ?? [.alignAllTop, .alignAllBottom], spacing: nil)
    }),
    .d([
      "col": [Item].self,
      "opts?": [PBLayoutConstraint.FormatOption].self,
    ], {
      try .col($0.x("col"), opts: $0.xq("opts") ?? [.alignAllLeading], spacing: nil)
    }),
    .d([
      "colPart": [Item].self,
      "opts?": [PBLayoutConstraint.FormatOption].self,
    ], {
      try .colPart($0.x("col"), opts: $0.xq("opts") ?? [.alignAllLeading], spacing: nil)
    }),
    .d([
      "colFixed": [String].self,
      "fixed": String.self,
      "height": CGFloat.self,
      "spacing": CGFloat.self,
    ], {
      try .colFixed($0.x("colFixed"), fixed: $0.x("fixed"), height: $0.x("height"), opts: [], spacing: $0.x("spacing"))
    }),
    .a("eq", [[String].self, PBLayoutConstraint.Attribute.self], {
      try .eq($0.x(1), parseConstraintAttribute($0.x(2)))
    }),
  ]
  
  static let jsRules: [JsParseRule<Self>] = [
    .a(["row", ".a", ".d?"], {
      let options = try? $0.obj(2)
      let opts = try parseConstraintFormatOptions(options) ?? [.alignAllTop, .alignAllBottom]
      return .row(try $0.x(1), opts: opts, spacing: nil)
    }),
    .a(["rowPart", ".a", ".d?"], {
      let options = try? $0.obj(2)
      let opts = try parseConstraintFormatOptions(options) ?? [.alignAllTop, .alignAllBottom]
      return .rowPart(try $0.x(1), opts: opts, spacing: nil)
    }),
    .a(["col", ".a", ".d?"], {
      let options = try? $0.obj(2)
      let opts = try parseConstraintFormatOptions(options) ?? [.alignAllLeading]
      return .col(try $0.x(1), opts: opts, spacing: nil)
    }),
    .a(["colPart", ".a", ".d?"], {
      let options = try? $0.obj(2)
      let opts = try parseConstraintFormatOptions(options) ?? [.alignAllLeading]
      return .colPart(try $0.x(1), opts: opts, spacing: nil)
    }),
    .a(["colFixed", ".a", ".d"], {
      let cfg = try $0.obj(2)
      return try .colFixed($0.x(1), fixed: cfg.x("fixed"), height: cfg.x("height"), opts: [], spacing: cfg.x("spacing"))
    }),
    .a(["eq", ".a", ".s"], {
      return try .eq($0.arr(1).x(), parseConstraintAttribute($0.x(2)))
    })
  ]
    
  static func parseConstraintFormatOptions(_ options: JSValue?) throws -> [PBLayoutConstraint.FormatOption]? {
    return try (try? options?.arr("opts"))?.map({
      let s: String = try $0.x()
      switch s {
      case "alignAllTop":
        return .alignAllTop
      case "alignAllBottom":
        return .alignAllBottom
      case "alignAllLeading":
        return .alignAllLeading
      case "alignAllTrailing":
        return .alignAllTrailing
      default:
        throw JSError.error(msg: "Unknown layout constraint option: \(s)")
      }
    })
  }
  
  static func parseConstraintAttribute(_ s: String) throws -> PBLayoutConstraint.Attribute {
    switch s {
    case "leading":
      return .leading
    case "trailing":
      return .trailing
    case "top":
      return .top
    case "bottom":
      return .bottom
    default:
      throw JSError.error(msg: "Unknown constraint attribute: \(s)")
    }
  }
  
}

extension PBLayoutConstraint.FormatOption: JsParsable {

  static let jsRules: [JsParseRule<Self>] = [
    .s("alignAllTop", { _ in .alignAllTop }),
    .s("alignAllBottom", { _ in .alignAllBottom }),
    .s("alignAllLeading", { _ in .alignAllLeading }),
    .s("alignAllTrailing", { _ in .alignAllTrailing }),
  ]

}

extension PBLayoutConstraint.Attribute: JsParsable {

  static let jsRules: [JsParseRule<Self>] = [
    .s("leading", { _ in .leading }),
    .s("trailing", { _ in .trailing }),
    .s("top", { _ in .top }),
    .s("bottom", { _ in .bottom }),
  ]

}

extension PatchController.Constraint.Item: JsParsable {
  static let jsRules: [JsParseRule<Self>] = [
    .a([".s", ".n"], { try .init($0.x(0), $0.x(1)) }),
  ]
}

extension PatchController.Constraint.Row: JsParsable {

  static let jsRules: [JsParseRule<Self>] = [
    .d([
      "row": ".a",
      "h": ".n",
    ], { try .init($0.x("row"), $0.x("h")) }),
  ]

}
