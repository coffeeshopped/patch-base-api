
import PBAPI
import JavaScriptCore

extension BasicModuleTruss: JsParsable {
  
  static let jsParsers: JsParseTransformSet<Self> = try! .init([
    ([
      "editor" : ".d",
      "sections" : ".a",
    ], {
      
      let editor: BasicEditorTruss = try $0.x("editor")
      let sections: [ModuleTrussSection] = try $0.x("sections")
      let manu: String = try $0.x("manu")
      let subid: String = try $0.x("subid")
      
      let colorGuide: ColorGuide
      if let arr = $0.forProperty("colorGuide"),
         let arrS = arr.toArray() as? [String] {
        colorGuide = ColorGuide(arrS)
      }
      else {
        colorGuide = ColorGuide([
          "#009f63",
          "#ec421e",
          "#717efe",
          "#79f11e",
        ])
      }

      return BasicModuleTruss(editor, manu: manu, model: editor.displayId, subid: subid, sections: sections, pathFn: nil, viewController: nil, dirMap: [:], colorGuide: colorGuide, indexPath: nil, configPaths: nil, postAddMsg: nil)
    }),
  ], "module")

}
