//
//  AbstractTheme.swift
//  BreakBaloon
//
//  Created by Emil on 16/08/2016.
//  Copyright © 2016 Snowy_1803. All rights reserved.
//

import Foundation
import SpriteKit

protocol AbstractTheme {
    var id: String { get }
    var name: String { get }
    
    var background: UIColor { get }
    var baloonCount: Int { get }
    
    func animationColor(type: Int) -> UIColor?
    
    func getBaloonTexture(status: Case.CaseStatus, type: Int, fake: Bool) -> SKTexture
    func getBaloonTexture(case aCase: Case) -> SKTexture
    func pumpSound(_ winner: Bool) -> Data
}

enum AbstractThemeUtils {
    static var themeList = AbstractThemeUtils.getThemeList()
    
    fileprivate static func getThemeList() -> [AbstractTheme] {
        var list = [AbstractTheme](arrayLiteral: DefaultTheme())
        for url in GameViewController.getExternalThemes() {
            let theme = parse(directoryUrl: url as URL)
            if theme != nil {
                list.append(theme!)
            }
        }
        print(list)
        return list
    }
    
    static func reloadThemeList() {
        themeList = getThemeList()
    }
    
    static func parse(directoryUrl url: URL) -> AbstractTheme? {
        if url.isDirectory { // isDirectory is defined in GameViewController
            let bbt1 = FileSaveHelper(fileName: url.lastPathComponent, fileExtension: .bbtheme, subDirectory: url.lastPathComponent)
            if bbt1.fileExists {
                do {
                    return try BBT1.parse(id: url.lastPathComponent, bbtheme: bbt1.getContentsOfFile())
                } catch {
                    print("Theme \(url.lastPathComponent)'s .bbtheme file couldn't be read")
                }
            }
            let bbt2 = FileSaveHelper(fileName: "theme", fileExtension: .bbtc, subDirectory: url.lastPathComponent)
            if bbt2.fileExists {
                do {
                    return try BBT2(dir: url.lastPathComponent, code: bbt2.getContentsOfFile())
                } catch {
                    print("Theme \(url.lastPathComponent)'s .bbtc file couldn't be read")
                }
            }
        }
        return nil
    }
    
    static func withID(_ id: String) -> AbstractTheme? {
        let index = themeList.firstIndex(where: { theme in
            theme.id == id
        })
        if index != nil {
            return themeList[index!]
        } else {
            return nil
        }
    }
}
