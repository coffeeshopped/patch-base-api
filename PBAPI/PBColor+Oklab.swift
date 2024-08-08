// Oklab Color Space
// https://bottosson.github.io/posts/oklab/

internal func clip<T: Comparable>(_ v: T, _ minimum: T, _ maximum: T) -> T {
  max(min(v, maximum), minimum)
}

public extension PBColor {

  // TODO: throw on invalid hex string
  convenience init(hexString: String) {
    let hexString = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
    let scanner   = Scanner(string: hexString)

    if hexString.hasPrefix("#") {
      scanner.scanLocation = 1
    }

    var hex: UInt32 = 0
    let useAlpha: Bool
    if scanner.scanHexInt32(&hex) {
      useAlpha = hexString.count > 7
    }
    else {
      hex = 0
      useAlpha = false
    }
    
    let cappedHex = !useAlpha && hex > 0xffffff ? 0xffffff : hex
    let r = cappedHex >> (useAlpha ? 24 : 16) & 0xff
    let g = cappedHex >> (useAlpha ? 16 : 8) & 0xff
    let b = cappedHex >> (useAlpha ? 8 : 0) & 0xff
    let a = useAlpha ? cappedHex & 0xff : 255

    let red   = CGFloat(r) / 255
    let green = CGFloat(g) / 255
    let blue  = CGFloat(b) / 255
    let alpha = CGFloat(a) / 255

    self.init(red: red, green: green, blue: blue, alpha: alpha)
  }

  
  convenience init(okL: CGFloat, a: CGFloat, b: CGFloat, alpha: CGFloat = 1) {
    
    let l_ = okL + 0.3963377774 * a + 0.2158037573 * b
    let m_ = okL - 0.1055613458 * a - 0.0638541728 * b
    let s_ = okL - 0.0894841775 * a - 1.2914855480 * b

    let l = l_ * l_ * l_
    let m = m_ * m_ * m_
    let s = s_ * s_ * s_

    
    let r = +4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s
    let g = -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s
    let b = -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s

    let rgb: (CGFloat) -> CGFloat = {
      if $0 >= 0.0031308 {
        return 1.055 * pow($0, 1.0 / 2.4) - 0.055
      }
      else {
        return 12.92 * $0
      }
    }
    let rr = clip(rgb(r), 0, 1)
    let gg = clip(rgb(g), 0, 1)
    let bb = clip(rgb(b), 0, 1)

    self.init(red: rr, green: gg, blue: bb, alpha: alpha)
  }

  // MARK: - Getting the Oklab Components

  final func toRGBAComponents() -> (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
    #if os(OSX)
    guard !isEqual(PBColor.black) else { return (0, 0, 0, 0) }
    guard !isEqual(PBColor.white) else { return (1, 1, 1, 1) }
    #endif
    
    var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
    getRed(&r, green: &g, blue: &b, alpha: &a)
    return (r, g, b, a)
  }
  
  final func toOklabComponents() -> (L: CGFloat, a: CGFloat, b: CGFloat) {
    
    let rgba = toRGBAComponents()
    
    // convert to linear rgb
    let lrgb: (CGFloat) -> CGFloat = {
      if $0 >= 0.04045 {
        return pow(($0 + 0.055) / (1 + 0.055), 2.4)
      }
      else {
        return $0 / 12.92
      }
    }
    let r = lrgb(rgba.r)
    let g = lrgb(rgba.g)
    let bb = lrgb(rgba.b)

    let l = 0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * bb
    let m = 0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * bb
    let s = 0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * bb

    let l_ = cbrt(l)
    let m_ = cbrt(m)
    let s_ = cbrt(s)

    let L = 0.2104542553 * l_ + 0.7936177850 * m_ - 0.0040720468 * s_
    let a = 1.9779984951 * l_ - 2.4285922050 * m_ + 0.4505937099 * s_
    let b = 0.0259040371 * l_ + 0.7827717662 * m_ - 0.8086757660 * s_
    
    return (L: L, a: a, b: b)
  }
    
  convenience init(okL: CGFloat, chroma: CGFloat, hue: CGFloat, alpha: CGFloat = 1) {
    let a = chroma * cos(hue * (.pi / 180))
    let b = chroma * sin(hue * (.pi / 180))
    self.init(okL: okL, a: a, b: b, alpha: alpha)
  }

  final func toOklabLchComponents() -> (L: CGFloat, chroma: CGFloat, hue: CGFloat) {
    let lab = toOklabComponents()
    let chroma = sqrt(lab.a * lab.a + lab.b * lab.b)
    let hue = atan2(lab.b, lab.a) * (180 / .pi)
    return (L: lab.L, chroma: chroma, hue: hue < 0 ? hue + .pi * 2 : hue)
  }
}
