//
//  AbstractGameScene.swift
//  BreakBaloon
//
//  Created by Emil on 29/07/2016.
//  Copyright © 2016 Snowy_1803. All rights reserved.
//

import AVFoundation
import SpriteKit

class AbstractGameScene: SKScene {
    var gametype: GameType
    
    var points: Int = 0
    
    var beginTime: TimeInterval?
    var endTime: TimeInterval?
    fileprivate var pauseTime: TimeInterval?
    
    private var normalPumpPlayers: Set<AVAudioPlayer> = []
    private var winnerPumpPlayers: Set<AVAudioPlayer> = []
    
    init(view: SKView, gametype: GameType) {
        self.gametype = gametype
        super.init(size: view.bounds.size)
        construct(view.gvc)
        view.gvc.currentGame = self
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func construct(_ gvc: GameViewController) {
        backgroundColor = gvc.currentTheme.background
    }
    
    func pauseGame() {
        pauseTime = Date().timeIntervalSince1970
        isPaused = true
    }
    
    func quitPause() {
        isPaused = false
        if beginTime != nil, pauseTime != nil {
            let pauseLenght = Date().timeIntervalSince1970 - pauseTime!
            beginTime! += pauseLenght
        }
        pauseTime = nil
    }
    
    func isGamePaused() -> Bool {
        pauseTime != nil
    }
    
    func playPump(winner: Bool) {
        let avplayer = (winner ? winnerPumpPlayers : normalPumpPlayers).first(where: { !$0.isPlaying }) ?? preparePlayer(winner: winner)
        avplayer?.play()
    }
    
    private func preparePlayer(winner: Bool) -> AVAudioPlayer? {
        do {
            let avplayer = try AVAudioPlayer(data: view!.gvc.currentTheme.pumpSound(winner))
            avplayer.volume = view!.gvc.audioVolume
            avplayer.prepareToPlay()
            if winner {
                winnerPumpPlayers.insert(avplayer)
            } else {
                normalPumpPlayers.insert(avplayer)
            }
            return avplayer
        } catch {
            print("Error playing sound <winner \(winner)>")
        }
        return nil
    }
}
