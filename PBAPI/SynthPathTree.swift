
//public typealias SynthPathInts = [SynthPath:Int]
public typealias SynthPathInts = SynthPathTree<Int>

//public func SynthPathIntsMake(_ other: [SynthPath:Int]) -> SynthPathInts { other }
public func SynthPathIntsMake(_ other: [SynthPath:Int]) -> SynthPathInts {
  SynthPathInts(dictionary: other)
}

//public typealias SynthPathParam = SynthPathTree<Param>
public typealias SynthPathParam = [SynthPath:Parm]

//public func MakeSynthPathParam(_ other: [SynthPath:Param]) -> SynthPathParam {
//  SynthPathParam(dictionary: other)
//}
public func MakeSynthPathParam(_ other: [SynthPath:Parm]) -> SynthPathParam {
  other
}


public struct SynthPathTree<T> : Sequence, ExpressibleByDictionaryLiteral {

  fileprivate var dict: [SynthPathItem:SynthPathTree<T>]?
  fileprivate var value: T?

  public typealias Key = SynthPath
  public typealias Value = T

  public struct Iterator: IteratorProtocol {
    private var iteratedValue: Bool = false
    private var treeValue: T?
    private var subtreeIndex = 0
    private var subtreeIterators: [(SynthPathItem, SynthPathTree<T>.Iterator)]?
    
    init(tree: SynthPathTree<T>) {
      treeValue = tree.value
      subtreeIterators = tree.dict?.map { ($0.key, $0.value.makeIterator()) }
    }
    
    public mutating func next() -> (key: Key, value: Value)? {
      // first see if we've iterated over the stored value
      if !iteratedValue {
        iteratedValue = true
        if let value = treeValue {
          return ([], value)
        }
      }
      
      // now iterate over the dictionary, if it exists
      while subtreeIndex < subtreeIterators?.count ?? 0 {
        if let nextValue = subtreeIterators?[subtreeIndex].1.next(),
           let prefixItem = subtreeIterators?[subtreeIndex].0 {
          return ([prefixItem] + nextValue.key, nextValue.value)
        }
        subtreeIndex += 1
      }
      
      return nil
    }
  }
  
  public func makeIterator() -> Iterator {
    Iterator(tree: self)
  }
  
  public init() { }

  public init(dictionaryLiteral elements: (SynthPath, T)...) {
    self.init()
    elements.forEach { self[$0.0] = $0.1 }
  }

  public init(_ dictionary: [Key:Value]) {
    self.init()
    dictionary.forEach { self[$0.key] = $0.value }
  }

  @available(*, deprecated, message: "Use the no-label init instead")
  public init(dictionary: [Key:Value]) {
    self.init()
    dictionary.forEach { self[$0.key] = $0.value }
  }

  public subscript(path: SynthPath) -> T? {
    get { self[path[0..<path.count]] }
    set { self[path[0..<path.count]] = newValue }
  }

  public subscript(path: ArraySlice<SynthPathItem>) -> T? {
    get {
      // 0-len subscript [] yields the value
      guard path.startIndex != path.endIndex else { return value }
      
      // >0-len subscript with no dictionary -> nil
      guard let dict = dict else { return nil }
      
      let first = path[path.startIndex]
      return dict[first]?[path[(path.startIndex + 1)...]]
    }
    set {
      guard path.startIndex != path.endIndex else { return value = newValue }
      
      if dict == nil {
        dict = [SynthPathItem:SynthPathTree<T>]()
      }

      let first = path[path.startIndex]
      if dict![first] == nil {
        dict![first] = SynthPathTree<T>()
      }
      dict![first]![path[(path.startIndex + 1)...]] = newValue
    }
  }

  
  
  public func debugOutput(depth: Int = 0) {
    let pad = String(repeating: "  ", count: depth)
    if let value = value {
      debugPrint("\(pad)-> \(value)")
    }
    dict?.forEach {
      debugPrint("\(pad)\($0.key):")
      $0.value.debugOutput(depth: depth + 1)
    }
  }
  
  public func filtered(forPrefix path: SynthPath?) -> SynthPathTree<T> {
    guard let path = path else { return self }
    return filtered(forPrefix: path[0..<path.count])
  }

  public func filtered(forPrefix path: ArraySlice<SynthPathItem>) -> SynthPathTree<T> {
    guard let first = path.first else { return self }
    return dict?[first]?.filtered(forPrefix: path.suffix(from: path.startIndex + 1)) ?? SynthPathTree<T>()
  }

  public func prefixed(_ path: SynthPath) -> SynthPathTree<T> {
    prefixed(path[0..<path.count])
  }

  public func prefixed(_ path: ArraySlice<SynthPathItem>) -> SynthPathTree<T> {
    guard path.endIndex > path.startIndex else { return self }
    let last = path[path.endIndex - 1]
    if path.endIndex - path.startIndex > 1 {
      return prefixed(last).prefixed(path[..<(path.endIndex - 1)])
    }
    else {
      return prefixed(last)
    }
  }

  public func prefixed(_ item: SynthPathItem) -> SynthPathTree<T> {
    var tree = SynthPathTree<T>()
    tree.dict = [item : self]
    return tree
  }
  
  // TODO: a way of caching this would be good
  public var count: Int {
    let valueCount = value == nil ? 0 : 1
    guard let dict = dict else { return valueCount }
    return dict.values.map { $0.count }.reduce(valueCount, +)
  }
  
  public var keys: [SynthPath] {
    (dict?.flatMap { pathItem, subTree in
      subTree.keys.map { [pathItem] + $0 }
    } ?? []) + (value == nil ? [] : [[]])
  }

  public var values: [T] {
    (dict?.values.flatMap {
      $0.values
    } ?? []) + (value == nil ? [] : [value!])
  }
  
  public mutating func removeAll(keepingCapacity: Bool) {
    value = nil
    dict?.removeAll(keepingCapacity: keepingCapacity)
  }
  
  public var first: (key: Key, value: Value)? {
    if let value = value {
      return ([], value)
    }
    
    return dict?.compactMap {
      guard let dictFirst = $0.value.first else { return nil }
      return ([$0.key] + dictFirst.key, dictFirst.value)
    }.first
  }
  
  public mutating func merge(new: Self) {
    new.forEach { self[$0.key] = $0.value }
  }
  
  public func merging(_ other: Self) -> Self {
    var me = self
    me.merge(new: other)
    return me
  }


  public mutating func removeValue(forKey key: SynthPath) {
    removeValue(forKey: key[0..<key.count])
  }

  public mutating func removeValue(forKey key: ArraySlice<SynthPathItem>) {
    guard let first = key.first else {
      value = nil
      return
    }
    guard key.count > 1 else {
      dict?[first]?.value = nil
      return
    }
    dict?[first]?.removeValue(forKey: key.suffix(from: key.startIndex + 1))
  }

}
