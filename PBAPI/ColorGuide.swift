
public struct ColorGuide {
  
  private let colors: [PBColor]
  private let tints: [[PBColor]]
  private let shades: [[PBColor]]
  public var darkMode: Bool
  
  private let lightPanels: [PBColor]
  private let lightValueBackgrounds: [PBColor]
  private let lightValues: [PBColor]
  
  public init() {
    self.init([
      "#db8a2d",
      "#15a9e8",
      "#ec9a2c",
      "#0ba6ff",
    ])
  }
  
  public init(_ c: [String], darkMode: Bool = false) {
    self.init(colors: c.map { PBColor(hexString: $0)})
  }
  
  public init(colors c: [PBColor], darkMode: Bool = false) {
    // just pull the hue from each.
    let colors: [PBColor] = c.map {
      let lch = $0.toOklabLchComponents()
      return PBColor(okL: 0.9, chroma: 0.22, hue: lch.hue)
    }
    self.colors = colors
    self.darkMode = darkMode
        
    tints = colors.map {
      let lch = $0.toOklabLchComponents()
      return [
        PBColor(okL: 0.96, chroma: 0.3, hue: lch.hue),
        PBColor(okL: 0.97, chroma: 0.2, hue: lch.hue),
        PBColor(okL: 0.98, chroma: 0.1, hue: lch.hue),
        PBColor(okL: 0.99, chroma: 0.06, hue: lch.hue),
        PBColor(okL: 1, chroma: 0.02, hue: lch.hue), // label text
    ] }
    shades = colors.map {
      let lch = $0.toOklabLchComponents()
      return [
        PBColor(okL: 0.5, chroma: 0.1, hue: lch.hue),
        PBColor(okL: 0.4, chroma: 0.05, hue: lch.hue), // tintBorder
        PBColor(okL: 0.3, chroma: 0.025, hue: lch.hue), // secondary bg (panel bg)
        PBColor(okL: 0.2, chroma: 0.025, hue: lch.hue), // tertiary bg (control value bg)
        PBColor(okL: 0.1, chroma: 0.025, hue: lch.hue), // background
    ] }
    
    lightPanels = colors.map {
      PBColor(okL: 0.98, chroma: 0.01, hue: $0.toOklabLchComponents().hue)
    }
    lightValueBackgrounds = colors.map {
      PBColor(okL: 0.95, chroma: 0.01, hue: $0.toOklabLchComponents().hue)
    }
    lightValues = colors.map {
      PBColor(okL: 0.95, chroma: 0.5, hue: $0.toOklabLchComponents().hue)
    }

  }

  public func textColor(level: Int = 1) -> PBColor {
    darkMode ? tints[level][4] : shades[level][4]
  }
  
  public func secondaryTextColor(level: Int = 1) -> PBColor {
    darkMode ? tints[level][3] : shades[level][3]
  }

  public func tintColor(level: Int = 1) -> PBColor {
    colors[level]
  }

  public func backgroundColor(level: Int = 1) -> PBColor {
    darkMode ? shades[level][4] : .white// tints[level][4]
  }
  
  public func secondaryBackgroundColor(level: Int = 1) -> PBColor {
    darkMode ? shades[level][2] : tints[level][2]
  }

  public func tertiaryBackgroundColor(level: Int = 1) -> PBColor {
    darkMode ? shades[level][3] : tints[level][3]
  }
  
  public func borderColor(level: Int = 1) -> PBColor {
    darkMode ? shades[level][1] : tints[level][1]
  }
  
  public func hintColor(level: Int = 1) -> PBColor {
    darkMode ? tints[level][0] : shades[level][0]
  }
  
  public func panelBackgroundColor(level: Int) -> PBColor {
    darkMode ? secondaryBackgroundColor(level: level) : lightPanels[level]
  }

  public func ctrlValueColor(level: Int) -> PBColor {
    darkMode ? tintColor(level: level) : lightValues[level]
  }

  public func ctrlValueBackgroundColor(level: Int) -> PBColor {
    darkMode ? tertiaryBackgroundColor(level: level) : lightValueBackgrounds[level]
  }

}
