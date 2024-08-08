
public extension Sequence {

  @available(*, deprecated, message: "Use dict instead")
  func dictionary<K, V>(transform:(_ element: Iterator.Element) -> [K : V]) -> [K : V] {
    map(transform).reduce([:], <<<)
  }

  func dict<K, V>(transform:(_ element: Iterator.Element) -> [K : V]) -> [K : V] {
    map(transform).reduce([:], <<<)
  }

  func compactDict<K, V>(transform:(_ element: Iterator.Element) -> [K : V]?) -> [K : V] {
    compactMap(transform).reduce([:], <<<)
  }

  func dict<K, V>(transform:(_ element: Iterator.Element) throws -> [K : V]) throws -> [K : V] {
    try map(transform).reduce([:], <<<)
  }

  func compactDict<K, V>(transform:(_ element: Iterator.Element) throws -> [K : V]?) throws -> [K : V] {
    try compactMap(transform).reduce([:], <<<)
  }

}
