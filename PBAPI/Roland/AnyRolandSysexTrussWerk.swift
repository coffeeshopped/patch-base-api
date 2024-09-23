
public protocol AnyRolandSysexTrussWerk {
//  var start: RolandAddress { get }
  var size: RolandAddress { get }
  func anyTruss(_ werk: RolandSysexTrussWerk, start: RolandAddress) throws -> any SysexTruss

//  func anySysexData(_ bodyData: SysexBodyData, deviceId: UInt8, address: RolandAddress) throws -> [[UInt8]]
}

public extension AnyRolandSysexTrussWerk {
  
  func bodyDataCheck<BodyData>(_ bodyData: SysexBodyData, bodyDataType: BodyData.Type) throws -> BodyData {
    guard let bd = bodyData.data() as? BodyData else {
      throw SysexTrussError.incorrectSysexType(msg: "Wrong bodyData type passed. Expected \(BodyData.self) but received \(type(of: bodyData.data()))")
    }
    return bd
  }
  
}
