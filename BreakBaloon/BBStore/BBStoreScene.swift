//
//  BBStoreScene.swift
//  BreakBaloon
//
//  Created by Emil on 27/06/2016.
//  Copyright © 2016 Snowy_1803. All rights reserved.
//

import Foundation
import SpriteKit

class BBStoreScene: SKScene, UISearchBarDelegate {
    let start: StartScene
    let gvc: GameViewController
    var downloads: [Downloadable]?
    var loading: SKLabelNode
    var errored = false
    var lastTouch: CGPoint?
    var touchBegin: CGPoint?
    var touchInterval: TimeInterval?
    fileprivate var decY: CGFloat = 0
    var title = SKLabelNode()
    var back = SKLabelNode()
    var upper = SKShapeNode()
    var search = UISearchBar()
    
    convenience init(start: StartScene) {
        self.init(start: start, size: start.view!.frame.size, gvc: start.view!.gvc)
    }
    
    init(start: StartScene, size: CGSize, gvc: GameViewController) {
        self.start = start
        self.gvc = gvc
        
        loading = SKLabelNode(text: NSLocalizedString("bbstore.loading", comment: "Loading text"))
        loading.fontColor = .foreground
        
        super.init(size: size)
        backgroundColor = .background
        loading.position = CGPoint(x: frame.width / 2, y: frame.height / 2 - 10)
        addChild(loading)
        beginBBStoreLoading()
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func beginBBStoreLoading() {
        DispatchQueue.global(qos: .default).async {
            do {
                self.downloads = try Downloadable.loadAll(gvc: self.gvc)
                DispatchQueue.main.async {
                    self.loading.run(SKAction.sequence([SKAction.fadeOut(withDuration: 1), SKAction.removeFromParent()]))
                    for dl in self.downloads! {
                        dl.alpha = 0
                        self.addChild(dl)
                        dl.run(SKAction.fadeIn(withDuration: 1))
                    }
                    self.adjustDownloadablePosition()
                    let topSA = self.view?.safeAreaInsets.top ?? 0
                    let top = self.frame.height - topSA
                    self.title = SKLabelNode(text: NSLocalizedString(UIDevice.current.userInterfaceIdiom != .pad ? "bbstore.button" : "bbstore.title", comment: "BBStore"))
                    self.title.fontColor = .foreground
                    self.title.fontSize = 20
                    self.title.position = CGPoint(x: self.frame.width / 2, y: top - 25)
                    self.title.alpha = 0
                    self.title.zPosition = 6
                    self.addChild(self.title)
                    self.title.run(SKAction.fadeIn(withDuration: 1))
                    self.back.text = UIDevice.current.orientation.isLandscape ? NSLocalizedString("back", comment: "") : "⬅︎  "
                    self.back.fontColor = .foreground
                    self.back.fontSize = 20
                    self.back.position = CGPoint(x: 5 + (self.view?.safeAreaInsets.left ?? 0), y: top - 25)
                    self.back.horizontalAlignmentMode = .left
                    self.back.alpha = 0
                    self.back.zPosition = 7
                    self.addChild(self.back)
                    self.back.run(SKAction.fadeIn(withDuration: 1))
                    self.upper = SKShapeNode(rect: CGRect(x: 0, y: top - 30, width: self.frame.width, height: 30 + topSA))
                    self.upper.fillColor = .background
                    self.upper.strokeColor = .clear
                    self.upper.alpha = 0.75
                    self.upper.zPosition = 5
                    self.addChild(self.upper)
                    
                    self.search = UISearchBar(frame: CGRect(x: self.frame.width - 150 - (self.view?.safeAreaInsets.right ?? 0), y: topSA, width: 150, height: 30))
                    self.search.placeholder = NSLocalizedString("bbstore.search", comment: "Search")
                    self.search.searchBarStyle = .minimal
                    self.search.isTranslucent = false
                    self.search.delegate = self
                    self.view?.addSubview(self.search)
                }
            } catch {
                DispatchQueue.main.async {
                    self.loading.text = NSLocalizedString("bbstore.error", comment: "Error text")
                    self.errored = true
                    let errorInfo = SKLabelNode(text: (error as NSError).localizedDescription)
                    errorInfo.position = CGPoint(x: self.loading.position.x, y: self.loading.position.y - 30)
                    errorInfo.fontColor = SKColor.black
                    self.addChild(errorInfo)
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with _: UIEvent?) {
        if errored {
            goBack()
        }
        if decY < 0 {
            if decY < -100 {
                title.run(SKAction.fadeOut(withDuration: 0.1))
                back.run(SKAction.fadeOut(withDuration: 0.1))
                upper.run(SKAction.fadeOut(withDuration: 0.1))
                search.removeFromSuperview()
                let transition = SKTransition.push(with: .down, duration: 0.3)
                transition.pausesOutgoingScene = false
                view?.presentScene(BBStoreScene(start: start, size: view!.frame.size, gvc: gvc), transition: transition)
            } else {
                decalageY(decY)
            }
        }
        if touches.count == 1 {
            let point = touches.first!.location(in: self)
            if back.frame.contains(point) {
                goBack()
            } else if downloads != nil, point.x + 10 > touchBegin!.x, point.x - 10 < touchBegin!.x, point.y + 10 > touchBegin!.y, point.y - 10 < touchBegin!.y {
                for dl in downloads! {
                    if children.contains(dl), dl.rect.frame.contains(touches.first!.location(in: dl)) {
                        dl.click(self)
                        break
                    }
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with _: UIEvent?) {
        // if transition == false {
        let point = touches.first?.location(in: self)
        if touches.count == 1, downloads != nil {
            decalageY(lastTouch!.y - point!.y)
        }
        lastTouch = point
        // }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with _: UIEvent?) {
        if touches.count == 1 {
            lastTouch = touches.first?.location(in: self)
            touchBegin = touches.first?.location(in: self)
            touchInterval = Date().timeIntervalSince1970
        }
    }
    
    func decalageY(_ decY: CGFloat) {
        self.decY -= decY
        
        for dl in downloads! {
            dl.position.y -= decY
        }
    }
    
    func goBack() {
        search.removeFromSuperview()
        view?.presentScene(start, transition: SKTransition.doorsOpenVertical(withDuration: 1))
    }
    
    func simulateClickOnDownload(_ id: String) {
        guard let downloads = downloads else {
            DispatchQueue.main.async {
                self.simulateClickOnDownload(id)
            }
            return
        }
        for dl in downloads where dl.dlid == id {
            print("Simulating download of \(dl.name ?? "(unnamed)")")
            dl.click(self)
        }
    }
    
    func searchBarTextDidBeginEditing(_ search: UISearchBar) {
        search.frame = CGRect(x: back.frame.width + 10 + (view?.safeAreaInsets.left ?? 0), y: view?.safeAreaInsets.top ?? 0, width: frame.width - back.frame.width - 5, height: 30)
        title.run(SKAction.fadeOut(withDuration: 0.2))
    }
    
    func searchBarTextDidEndEditing(_: UISearchBar) {
        search.frame = CGRect(x: frame.width - 150 - (view?.safeAreaInsets.right ?? 0), y: view?.safeAreaInsets.top ?? 0, width: 150, height: 30)
        title.run(SKAction.fadeIn(withDuration: 0.2))
    }
    
    func searchBar(_: UISearchBar, textDidChange _: String) {
        adjustDownloadablePosition()
    }
    
    func adjustDownloadablePosition() {
        let insets = view?.safeAreaInsets ?? UIEdgeInsets()
        let cols = Int(frame.inset(by: insets).width / Downloadable.WIDTH)
        var i = 0
        for dl in downloads! {
            if search.text!.isEmpty || dl.dlname.lowercased().contains(search.text!.lowercased()) {
                if dl.parent == nil {
                    addChild(dl)
                }
                dl.position = CGPoint(
                    x: CGFloat(i % cols) * (Downloadable.WIDTH + 5) + 5 + insets.left,
                    y: frame.height - insets.top - (CGFloat(i / cols) * (Downloadable.HEIGHT + 5) + 30 + Downloadable.HEIGHT))
                i += 1
            } else {
                dl.removeFromParent()
            }
        }
    }
}

extension UIColor {
    static var foreground: UIColor {
        if #available(iOS 13, *) {
            return .label
        } else {
            return .black
        }
    }
    
    static var background: UIColor {
        if #available(iOS 13, *) {
            return .secondarySystemGroupedBackground
        } else {
            return .white
        }
    }
}
