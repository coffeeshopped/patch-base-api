
import PBAPI
import JavaScriptCore

extension BasicModuleTruss: JsParsable {
  
  static let jsParsers: JsParseTransformSet<Self> = try! .init([
    ([
      "editor" : ".d",
      "sections" : ".a",
    ], {
      
      let editor: BasicEditorTruss = try $0.xform("editor")
      let sections: [ModuleTrussSection] = try $0.xform("sections")
      let manu = try $0.str("manu")
      let subid = try $0.str("subid")
      
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
