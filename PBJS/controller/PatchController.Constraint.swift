
import PBAPI
import JavaScriptCore

extension PatchController.Constraint: JsParsable {
  
  public static let jsRules: [JsParseRule<Self>] = [
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
