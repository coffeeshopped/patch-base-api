
import PBAPI
import JavaScriptCore

extension PatchController.Constraint: JsParsable {
  
  public static let jsRules: [JsParseRule<Self>] = [
    .a("row", [[Item].self], optional: [JsObj.self], {
      let config = try? $0.obj(2)
      return try .row($0.x(1), opts: config?.xq("opts") ?? [.alignAllTop, .alignAllBottom], spacing: nil)
    }),
    .a("rowPart", [[Item].self], optional: [JsObj.self], {
      let config = try? $0.obj(2)
      return try .rowPart($0.x(1), opts: config?.xq("opts") ?? [.alignAllTop, .alignAllBottom], spacing: nil)
    }),
    .a("col", [[Item].self], optional: [JsObj.self], {
      let config = try? $0.obj(2)
      return try .col($0.x(1), opts: config?.xq("opts") ?? [.alignAllLeading], spacing: nil)
    }),
    .a("colPart", [[Item].self], optional: [JsObj.self], {
      let config = try? $0.obj(2)
      return try .colPart($0.x(1), opts: config?.xq("opts") ?? [.alignAllLeading], spacing: nil)
    }),
    .a("colFixed", [[String].self, JsObj.self], {
      let config = try $0.obj(2)
      return try .colFixed($0.x(1), fixed: config.x("fixed"), height: config.x("height"), opts: [], spacing: config.x("spacing"))
    }),
    .a("eq", [[String].self, PBLayoutConstraint.Attribute.self], {
      try .eq($0.x(1), $0.x(2))
    }),
  ]
  
}

extension PBLayoutConstraint.FormatOption: JsParsable {

  public static let jsRules: [JsParseRule<Self>] = [
    .s("alignAllTop", { _ in .alignAllTop }),
    .s("alignAllBottom", { _ in .alignAllBottom }),
    .s("alignAllLeading", { _ in .alignAllLeading }),
    .s("alignAllTrailing", { _ in .alignAllTrailing }),
  ]
  
}

extension PBLayoutConstraint.Attribute: JsParsable {

  public static let jsRules: [JsParseRule<Self>] = [
    .s("leading", { _ in .leading }),
    .s("trailing", { _ in .trailing }),
    .s("top", { _ in .top }),
    .s("bottom", { _ in .bottom }),
  ]

}

extension PatchController.Constraint.Item: JsParsable {
  public static let jsRules: [JsParseRule<Self>] = [
    .arr([String.self, CGFloat.self], { try .init($0.x(0), $0.x(1)) }),
  ]
}

extension PatchController.Constraint.Row: JsParsable {

  public static let jsRules: [JsParseRule<Self>] = [
    .d([
      "row": [PatchController.Constraint.Item].self,
      "h": CGFloat.self,
    ], { try .init($0.x("row"), $0.x("h")) }),
  ]

}
