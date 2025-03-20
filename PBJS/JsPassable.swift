import PBAPI

protocol JsPassable {
  func toJS() -> AnyHashable
}

extension Int : JsPassable {
  func toJS() -> AnyHashable { self }
}

extension String : JsPassable {
  func toJS() -> AnyHashable { self }
}

extension CGFloat : JsPassable {
  func toJS() -> AnyHashable { self }
}

extension Dictionary : JsPassable where Key: JsPassable, Value: JsPassable {
  func toJS() -> AnyHashable {
    var d = [AnyHashable:AnyHashable]()
    forEach {
      d[$0.key.toJS()] = $0.value.toJS()
    }
    return d
  }
}

extension Array : JsPassable where Element: JsPassable {
  func toJS() -> AnyHashable {
    map { $0.toJS() }
  }
}

extension SynthPathInts : JsPassable {
  func toJS() -> AnyHashable {
    var d = [AnyHashable:AnyHashable]()
    forEach {
      d[$0.key.str()] = $0.value
    }
    return d
  }
}
