
public struct Iso<A, B> {
  public let forward: (A) -> B
  public let backward: (B) -> A
  
  public init(forward: @escaping (A) -> B, backward: @escaping (B) -> A) {
    self.forward = forward
    self.backward = backward
  }
}

public extension Iso where A: Numeric, A == B {

  /// Add
  static func a(_ x: A) -> Iso<A, A> {
      .init(
          forward: { $0 + x },
          backward: { $0 - x }
      )
  }

}

public func >>><A, B, C>(_ lhs: Iso<A, B>, _ rhs: Iso<B, C>) -> Iso<A, C> {
  Iso<A, C>(
    forward: { a in rhs.forward(lhs.forward(a)) },
    backward: { c in lhs.backward(rhs.backward(c)) }
  )
}

infix operator >>>: MultiplicationPrecedence

public func >>>(_ lhs: IsoFF, _ rhs: IsoFF) -> IsoFF {
  IsoFF(
    forward: { a in rhs.forward(lhs.forward(a)) },
    backward: { c in lhs.backward(rhs.backward(c)) }
  )
}

public func >>>(_ lhs: IsoFF, _ rhs: IsoFS) -> IsoFS {
  IsoFS(
    forward: { a in rhs.forward(lhs.forward(a)) },
    backward: { c in lhs.backward(rhs.backward(c)) }
  )
}

