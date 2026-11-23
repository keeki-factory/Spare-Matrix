//
//  TimeAttackViewModel+Pause.swift
//  LinearPractice
//  
//  Created by keeki-fami on 2026/11/23
//  
//
import SwiftUI
// 中断の部分
extension TimeAttackViewModel {
    // ボタンを戻す
    func backToGame() {
        self.showPauseButton = false
    }
    
    // 再挑戦する
    func restart() {
        SoundPlayer.shared.play(.resultAppear)
        BGMPlayer.shared.fadeStop()
        moveWithWhiteSpace(after: .playing(.before), white: {
            self.userInput = ""
            self.showPauseButton = false
            self.stop()
            self.remainingSeconds = CGFloat(self.gameTime)
            self.countdown = 3
            self.score = 0
            self.combo = 0
            self.isPushedBeforeState = false
            self.gameTimer = nil
        })
    }
    
    // ゲームをやめてホーム画面に戻る
    func backToHome() {
        
    }
}
