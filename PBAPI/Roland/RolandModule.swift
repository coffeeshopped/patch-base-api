
public extension ModuleTrussSection.Item {
  
  static func deviceId(_ title: String = "Device ID") -> Self {
    .init(title, [.deviceId], .custom(.patch(color: 1, [
      .grid([[
        .knob("Device ID", [.deviceId])
      ]])
    ])))
  }
}
