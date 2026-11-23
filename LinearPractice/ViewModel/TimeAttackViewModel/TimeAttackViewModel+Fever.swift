//
//  TimeAttackViewModel+Fever.swift
//  LinearPractice
//  
//  Created by keeki-fami on 2026/11/23
//  
//
import SwiftUI
import Combine

// fever
extension TimeAttackViewModel {
    var progress: Double {
        remainingTime / totalTime
    }
    
    func feverStart() {
        guard !isRunning else { return }

        if remainingTime <= 0 {
            feverReset()
        }

        isRunning = true

        timer = Timer.publish(
            every: 0.1,
            on: .main,
            in: .common
        )
        .autoconnect()
        .sink { [weak self] _ in
            guard let self else { return }

            if remainingTime > 0 {
                remainingTime = max(0, remainingTime - 0.1)
            }

            if remainingTime <= 0 {
                print("aaa")
                feverStop()
                self.combo = 0
                withAnimation {
                    self.feverPhase = .normal
                }
            }
        }
    }
    
    func feverPause() {
        feverStop()
    }

    // タイマー停止
    private func feverStop() {
        timer?.cancel()
        timer = nil
        isRunning = false
    }

    // リセット
    func feverReset() {
        feverStop()
        remainingTime = totalTime
    }
}
