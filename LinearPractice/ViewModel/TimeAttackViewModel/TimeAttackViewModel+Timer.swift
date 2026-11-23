//
//  TimeAttackViewModel+Timer.swift
//  LinearPractice
//  
//  Created by keeki-fami on 2026/11/23
//  
//
import SwiftUI
import Combine

// timer
extension TimeAttackViewModel {
    func start_count() {
        nowPhase = .playing(.before)
        remainingSeconds = CGFloat(gameTime)
        countdown = 3
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            print("\(self.countdown)")
            if self.countdown > 1 {
                SoundPlayer.shared.play(.countdown)
                print(self.countdown)
                self.countdown -= 1
            } else {
                self.countdownTimer?.invalidate()
//                self.start()
                self.new_start()
                self.nowPhase = .playing(.playing(.normal))
//                self.playingPhase = .playing()
                BGMPlayer.shared.play(.buttleBGM)
            }
        }
    }
    
    func new_start() {
        remainingSeconds = 60.0
        gameTimer = Timer.publish(
            every: 0.1,
            on: .main,
            in: .common
        )
        .autoconnect()
        .sink { [weak self] _ in
            if self?.showPauseButton != true {
                guard let self else { return }
                
                if remainingSeconds > 0.0 {
                    remainingSeconds = max(0.0, remainingSeconds - 0.1)
                }
                
                if remainingSeconds <= 0.0 {
                    do {
                        Task {
                            self.gameTimer?.cancel()
                            self.nowPhase = .playing(.done)
                            BGMPlayer.shared.stop()
                            SoundPlayer.shared.play(.timeAttackFinish)
                            try await Task.sleep(nanoseconds: 3_000_000_000)
                            self.moveWithWhiteSpace(after:.result, white: {})
                        }
                    } 
                }
            }
        }
    }
    
    // pause画面から終了する場合
    func pauseQuit() {
        do {
                self.gameTimer?.cancel()
//                self.nowPhase = .playing(.done)
                BGMPlayer.shared.stop()
//                SoundPlayer.shared.play(.timeAttackFinish)
//                try await Task.sleep(nanoseconds: 3_000_000_000)
                self.moveWithWhiteSpace(after:.result, white: {})
            
        } catch {
            print("fail to task")
        }
    }

    func start() {
        
        self.timerTask?.cancel()
        self.timerTask = Task { @MainActor [weak self] in
            for _ in 0..<gameTime {
                do {
                    try await Task.sleep(nanoseconds: 1_000_000_000)
                } catch {
                    return
                }

                guard let self, !Task.isCancelled, (self.nowPhase == .playing(.playing(.normal)) || self.nowPhase == .playing(.playing(.fever))) else {
                    return
                }
                self.remainingSeconds -= 1
            }
            
            guard let self, (self.nowPhase == .playing(.playing(.normal)) || self.nowPhase == .playing(.playing(.fever))) else { return }
            
            do {
                self.nowPhase = .playing(.done)
                BGMPlayer.shared.stop()
                SoundPlayer.shared.play(.timeAttackFinish)
                try await Task.sleep(nanoseconds: 3_000_000_000)
                moveWithWhiteSpace(after:.result, white: {})
            } catch {
                
            }
        }
    }
    

    func stop() {
        timerTask?.cancel()
        timerTask = nil
    }
}
