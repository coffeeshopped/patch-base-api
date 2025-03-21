
import PBAPI
import JavaScriptCore

extension PatchController.Constraint: JsParsable {
  
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
  
  static let gridRowRules: [JsParseRule<([Self.Item], CGFloat)>] = [
//    (".a", { (try $0.xform(), CGFloat(1)) }),
    .d([
      "row": ".a",
      "h": ".n",
    ], { (try $0.x("row"), try $0.x("h")) }),
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

extension PatchController.Constraint.Item: JsParsable {
  static let jsRules: [JsParseRule<Self>] = [
    .a([".s", ".n"], { try .init($0.x(0), $0.x(1)) }),
  ]
}
