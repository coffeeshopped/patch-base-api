
public struct DXOp {
  public let opId: Int
  public var inputs = [Int]()
  public var outputs = [Int]()
  public var feedbackInputs = [Int]()
  public var feedbackOutputs = [Int]()
  
  init(opId: Int) {
    self.opId = opId
  }
  
  public func input(_ index: Int) -> Int? {
    if inputs.count > index {
      return inputs[index]
    }
    else if feedbackInputs.count > index + inputs.count {
      return feedbackInputs[index - inputs.count]
    }
    return nil
  }
}

public struct DXAlgorithm {
  
  public var ops = [DXOp]()
  public var outputOps = [Int]()
  public var inputOps = [Int]()
  public var opHeight: Int = 0
  public var feedbackSrcOps = Set<Int>() // added for TG77
  public var branches = [[Int]]() // op ids grouped by branch

  public var opWidth: Int { max(outputOps.count, inputOps.count) }
  
  init() { }
  
  // NO JUNK/ZERO ELEMENT for this init
  // 1-based ids in the data.
  public init(_ array: [[String:[Int]]]) {
    let opCount = array.count
    makeOps(opCount)
    
    opCount.forEach { opId in
      let dict = array[opId]
      let outputs = (dict["outs"] ?? []).map({ $0 - 1 })
      let feedbackOutputs = (dict["feedOuts"] ?? []).map({ $0 - 1 })
      configOp(opId, outputs, feedbackOutputs)
    }
    
    calcAlgoProps()
  }
    
  // 0th element is junk
  // 1-based ids in the data.
  init(array: [[String:[Int]]]) {
    let opCount = array.count - 1 // 0th element is junk
    makeOps(opCount)

    opCount.forEach { opId in
      let dict = array[opId + 1]
      let outputs = (dict["outputs"] ?? []).map({ $0 - 1 })
      let feedbackOutputs = (dict["feedbackOutputs"] ?? []).map({ $0 - 1 })
      configOp(opId, outputs, feedbackOutputs)
    }
    
    calcAlgoProps()
  }
  
  // NO JUNK/ZERO ELEMENT for this init
  // ZERO-based ids in the data.
  public init(zeroBased array: [[String:[Int]]]) {
    let opCount = array.count
    makeOps(opCount)

    opCount.forEach { opId in
      let dict = array[opId]
      let outputs = dict["outs"] ?? []
      let feedbackOutputs = dict["feedOuts"] ?? []
      configOp(opId, outputs, feedbackOutputs)
    }
    
    calcAlgoProps()
  }
  
  private mutating func makeOps(_ opCount: Int) {
    ops = opCount.map { DXOp(opId: $0) }
  }
    
  private mutating func configOp(_ opId: Int, _ outputs: [Int], _ feedbackOutputs: [Int]) {
    ops[opId].outputs = outputs
    // add corresponding input to the referenced op
    outputs.forEach { ops[$0].inputs.append(opId) }

    ops[opId].feedbackOutputs = feedbackOutputs
    feedbackOutputs.forEach {
      // add corresponding input to the referenced op
      ops[$0].feedbackInputs.append(opId)
      // add to the algo
      feedbackSrcOps.insert($0)
    }
  }
  
  private mutating func calcAlgoProps() {
    let opCount = ops.count
    inputOps = (0..<opCount).filter { ops[$0].inputs.count == 0 }
    outputOps = (0..<opCount).filter { ops[$0].outputs.count == 0 }
    
    ops.forEach {
      var tempHeight = 1
      var op = $0
      while let output = op.outputs.first {
        tempHeight += 1
        op = ops[output]
      }
      opHeight = max(opHeight, tempHeight)
    }
    
    calcBranches()
  }
  
  private mutating func calcBranches() {
    ops.forEach {
      let opId = $0.opId
      if let branchId = findBranchId(op: opId, checked: []) {
        branches[branchId].append(opId)
      }
      else {
        branches.append([opId])
      }
    }
  }
  
  private func findBranchId(op: Int, checked: [Int]) -> Int? {
    // if no branches exist, there's no branchId
    guard !branches.isEmpty else { return nil }
    
    // if an existing branch holds this id, return branch Id
    if let branchId = branches.enumerated().filter({
      $0.element.contains(op)
    }).first?.offset {
      return branchId
    }
    
    let newChecked = checked + [op]
    
    // check inputs (omitting checked)
    if let branchId = ops[op].inputs.filter({ !newChecked.contains($0) }).compactMap({
      findBranchId(op: $0, checked: newChecked)
    }).first {
      return branchId
    }
    
    // check outputs (omitting checked)
    if let branchId = ops[op].outputs.filter({ !newChecked.contains($0) }).compactMap({
      findBranchId(op: $0, checked: newChecked)
    }).first {
      return branchId
    }
    
    return nil
  }

  
  // cache algos read from files
  private static var algorithmsDict = [String:[DXAlgorithm]]()

  class Foo { }
  
  public static func algorithmsFromPlist(_ plist: String) -> [DXAlgorithm] {
    guard algorithmsDict[plist] == nil else { return algorithmsDict[plist] ?? [] }

    guard let path = Bundle(for: Foo.self).path(forResource: plist, ofType:"plist"),
      let structure = NSDictionary(contentsOfFile:path),
      let algoStructures = structure["algorithms"] as? [[[String:[Int]]]] else { return [] }
    
    // ignore 0th element
    let ma = (1..<algoStructures.count).map { DXAlgorithm(array: algoStructures[$0]) }

    algorithmsDict[plist] = ma
    
    return ma
  }
  
  public static func algorithms(fromJSON data: Data, key: String) -> [DXAlgorithm] {
    guard algorithmsDict[key] == nil else { return algorithmsDict[key]! }

    var v = [String:[[String:[Int]]]]()
    do {
      v = try JSONDecoder().decode(type(of: v), from: data)
    } catch {
      print("Unexpected error: \(error).")
    }

    var algos = [DXAlgorithm](repeating: DXAlgorithm(), count: v.count)
    v.forEach {
      guard let index = Int($0.key),
        index < v.count else { return }
      algos[index] = DXAlgorithm(zeroBased: $0.value)
    }
    algorithmsDict[key] = algos
    return algorithmsDict[key]!
  }
}
