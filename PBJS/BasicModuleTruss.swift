
import PBAPI
import JavaScriptCore

extension BasicModuleTruss: JsParsable {
  
  static let nuJsRules: [NuJsParseRule<Self>] = [
    .d([
      "editor" : BasicEditorTruss.self,
      "sections" : [ModuleTrussSection].self,
      "manu" : String.self,
      "subid" : String.self,
      "colorGuide?" : [String].self,
      "dirMap?" : [SynthPath:String].self,
    ], {
      let editor: BasicEditorTruss = try $0.x("editor")
      let colors: [String] = try $0.xq("colorGuide") ?? [
        "#009f63",
        "#ec421e",
        "#717efe",
        "#79f11e",
      ]
      return try BasicModuleTruss(editor, manu: $0.x("manu"), model: editor.displayId, subid: $0.x("subid"), sections: $0.x("sections"), pathFn: nil, viewController: nil, dirMap: $0.xq("dirMap") ?? [:], colorGuide: ColorGuide(colors), indexPath: nil, configPaths: nil, postAddMsg: nil)
    }),
  ]
  
  static let jsRules: [JsParseRule<Self>] = [
    .d([
      "editor" : ".d",
      "sections" : ".a",
    ], {
      let editor: BasicEditorTruss = try $0.x("editor")
      let colors: [String] = try $0.xq("colorGuide") ?? [
        "#009f63",
        "#ec421e",
        "#717efe",
        "#79f11e",
      ]
      return try BasicModuleTruss(editor, manu: $0.x("manu"), model: editor.displayId, subid: $0.x("subid"), sections: $0.x("sections"), pathFn: nil, viewController: nil, dirMap: $0.xq("dirMap") ?? [:], colorGuide: ColorGuide(colors), indexPath: nil, configPaths: nil, postAddMsg: nil)
    }),
  ]

}
