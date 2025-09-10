
import PBAPI
import JavaScriptCore

extension ModuleTruss: JsParsable {
  
  public static let jsRules: [JsParseRule<Self>] = [
    .d([
      "editor" : EditorTruss.self,
      "sections" : [ModuleTrussSection].self,
      "manu" : String.self,
      "subid" : String.self,
      "colorGuide?" : [String].self,
      "dirMap?" : [SynthPath:String].self,
    ], {
      let editor: EditorTruss = try $0.x("editor")
      let colors: [String] = try $0.xq("colorGuide") ?? [
        "#009f63",
        "#ec421e",
        "#717efe",
        "#79f11e",
      ]
      return try ModuleTruss(editor, manu: $0.x("manu"), model: editor.displayId, subid: $0.x("subid"), sections: $0.x("sections"), pathFn: nil, viewController: nil, dirMap: $0.xq("dirMap") ?? [:], colorGuide: ColorGuide(colors), indexPath: nil, configPaths: nil, postAddMsg: nil)
    }, "basic"),
  ]

}
