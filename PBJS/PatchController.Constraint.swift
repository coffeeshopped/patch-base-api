
import PBAPI
import JavaScriptCore

extension PatchController.Constraint: JsParsable, JsArrayParsable {
  
  static let jsParsers: JsParseTransformSet<Self> = try! .init([
    (["row", ".a", ".d?"], {
      let items = try parseConstraintItems($0.arr(1))
      let options = try? $0.obj(2)
      let opts = try parseConstraintFormatOptions(options) ?? [.alignAllTop, .alignAllBottom]
      return .row(items, opts: opts, spacing: nil)
    }),
    (["rowPart", ".a", ".d?"], {
      let items = try parseConstraintItems($0.arr(1))
      let options = try? $0.obj(2)
      let opts = try parseConstraintFormatOptions(options) ?? [.alignAllTop, .alignAllBottom]
      return .rowPart(items, opts: opts, spacing: nil)
    }),
    (["col", ".a", ".d?"], {
      let items = try parseConstraintItems($0.arr(1))
      let options = try? $0.obj(2)
      let opts = try parseConstraintFormatOptions(options) ?? [.alignAllLeading]
      return .col(items, opts: opts, spacing: nil)
    }),
    (["colPart", ".a", ".d?"], {
      let items = try parseConstraintItems($0.arr(1))
      let options = try? $0.obj(2)
      let opts = try parseConstraintFormatOptions(options) ?? [.alignAllLeading]
      return .colPart(items, opts: opts, spacing: nil)
    }),
    (["eq", ".a", ".s"], {
      return .eq(try $0.arr(1).arrStr(), try parseConstraintAttribute(try $0.any(2).str()))
    })
  ], "controller constraint")
  
  static let jsArrayParsers = try! jsParsers.arrayParsers()
  
  static func parseConstraintItems(_ value: JSValue) throws -> [PatchController.Constraint.Item] {
    try value.map { (try $0.any(0).str(), try $0.cgFloat(1)) }
  }
  
  static func parseConstraintFormatOptions(_ options: JSValue?) throws -> [PBLayoutConstraint.FormatOption]? {
    return try (try? options?.arr("opts"))?.map({
      let s = try $0.str()
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
