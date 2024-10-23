
public enum ModuleTrussSection {
  
  case basic(_ title: String?, _ items: [Item])
  case backup
  
  public var title: String? {
    switch self {
    case .basic(let title, _):
      return title
    case .backup:
      return "Backup"
    }
  }

  public var items: [Item] {
    switch self {
    case .basic(_, let items):
      return items
    case .backup:
      return [.backup]
    }
  }

  
  public struct Item {
    public let title: String
    public let path: SynthPath
    public let controller: ModuleTrussController
    
    public init(_ title: String, _ path: SynthPath, _ controller: ModuleTrussController) {
      self.title = title
      self.path = path
      self.controller = controller
    }
    
    public static let backup = Self.init("Backup", [.backup], .backup)
    
  }
}

public extension ModuleTrussSection {
  
  static func first(_ items: [Item]) -> Self {
    .basic(nil, items)
  }

  static func banks(_ items: [Item]) -> Self {
    .basic("Banks", items)
  }

}

public extension ModuleTrussSection.Item {
  
  static func global(_ ctrlr: PatchController, title: String? = nil) -> Self {
    .init(title ?? "Global", [.global], .custom(ctrlr))
  }

  static func channel(_ knobLabel: String = "MIDI Channel") -> Self {
    .global(.patch(color: 1, [.grid([[.knob(knobLabel, [.channel])]]),]))
  }

  static func custom(_ title: String, _ path: SynthPath = [.patch], _ ctrlr: PatchController) -> Self {
    .init(title, path, .custom(ctrlr))
  }

  static func voice(_ title: String, path: SynthPath? = nil, _ ctrlr: PatchController) -> Self {
    .init(title, path ?? [.patch], .voice(ctrlr))
  }

  static func perf(title: String = "Performance", path: SynthPath = [.perf], _ ctrlr: PatchController) -> Self {
    .init(title, path, .perf(ctrlr))
  }

  static func bank(_ title: String, _ path: SynthPath) -> Self {
    .init(title, path, .bank)
  }
  
  static func fullRef(title: String = "Full Perf", path: SynthPath = [.extra, .perf]) -> Self {
    .init(title, path, .fullRef)
  }

}

public extension Array where Element == ModuleTrussSection.Item {
  
  static func perfParts(_ count: Int, _ title: (Int) throws -> String, pathPrefix: SynthPath = [.part], _ ctrlr: PatchController) throws -> Self {
    try count.map { try .voice(title($0), path: pathPrefix + [.i($0)], ctrlr) }
  }

  static func banks(_ count: Int, _ title: (Int) -> String, _ pathPrefix: SynthPath) -> Self {
    count.map { .bank(title($0), pathPrefix + [.i($0)]) }
  }

}
