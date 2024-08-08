
public struct SOPCMCard {
  
  public let name: String
  public let waves: [String]
  public let patches: [String]
  
  public static let cards: [Int:SOPCMCard] = [
    1 : piano,
    2 : guitarBrass,
    3 : drums,
    4 : grand,
    5 : accordion,
    6 : baroque,
    7 : orch,
    8 : country,
    ]
  
  public static let cardNameOptions: [Int:String] = {
    var options = [Int:String]()
    SOPCMCard.cards.forEach { options[$0] = $1.name }
    return options
  }()
  
  static let piano = SOPCMCard(name: "Piano Selections", waves: [], patches: [])
  static let guitarBrass = SOPCMCard(name: "Guitar and Brass", waves: [], patches: [])
  static let drums = SOPCMCard(name: "Rock Drums", waves: [], patches: [])
  static let grand = SOPCMCard(name: "Grand Piano", waves: [], patches: [])
  static let accordion = SOPCMCard(name: "Accordion", waves: [], patches: [])
  static let baroque = SOPCMCard(name: "Baroque", waves: [], patches: [])
  static let orch = SOPCMCard(name: "Orchestral FX", waves: [], patches: [])
  static let country = SOPCMCard(name: "Country/Folk/Bluegrass", waves: [], patches: [])

}
