import PBAPI

protocol JsPassable {
  func toJS() -> Any
}

extension Int : JsPassable {
  func toJS() -> Any { self }
}

extension String : JsPassable {
  func toJS() -> Any { self }
}

extension Dictionary : JsPassable where Key: JsPassable, Value: JsPassable {
  func toJS() -> Any {
    var d = [AnyHashable:Any]()
    forEach {
      d[$0.key.toJS() as! AnyHashable] = $0.value.toJS()
    }
    return d
  }
}

extension SynthPathInts : JsPassable {
  func toJS() -> Any {
    dict { [$0.key.str() : $0.value] }
  }
}
