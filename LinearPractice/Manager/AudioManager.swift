//
//  AudioManager.swift
//  LinearPractice
//  
//  Created by keeki-fami on 2026/11/09
//  
//
import AVFoundation

enum BGMComponent: String {
    case titleBGM = "titleBGM"
    case buttleBGM = "playingTimeAttack"
    case homeBGM = "home"
}

enum SoundComponent: String {
    case problemCorrect = "success"
    case timeAttackFinish = "timeattackFinish"
    case resultAppear = "resultAppear"
    case tap = "tap"
    case countdown = "countdown"
}

// BGM
class BGMPlayer {
    
    private var audioPlayer: AVAudioPlayer?
    static let shared = BGMPlayer()
    var nowPlaying: BGMComponent?
    
    func play(_ component: BGMComponent) {
        
        // 再生中の音楽を再生しようとしている場合
        if let nowPlaying = self.nowPlaying, nowPlaying == component {
            print("音楽を再再生しようとしました")
            return
        } else {
            print("音楽を再生します")
        }
        
        nowPlaying = component
        guard let url = Bundle.main.url(
            forResource: component.rawValue,
            withExtension: "mp3"
        ) else {
            print("MP3ファイルが見つかりません")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1 // 無限ループ
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            print("再生しました: \(component.rawValue)")
        } catch {
            print("再生エラー: \(error)")
        }
    }
    
    // だんだん音を小さくしてストップする
    func fadeStop() {
        print("ストップします")
        audioPlayer?.setVolume(0.0, fadeDuration: 0.35) //1秒かけてvolumeを0にする

        // 1秒後に再生をストップする
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            self.audioPlayer?.stop()
            self.audioPlayer?.currentTime = 0 // 現在の再生時間を00:00に戻す
        }
        nowPlaying = nil
        print("ストップしました")
    }
    
    // ストップする
    func stop() {
        self.audioPlayer?.stop()
        self.audioPlayer?.currentTime = 0
        nowPlaying = nil
        print("ストップしました")
    }
    
}

// 効果音
class SoundPlayer {
    private var audioPlayer: AVAudioPlayer?
    static let shared = SoundPlayer()

    func play(_ component: SoundComponent) {
        guard let url = Bundle.main.url(
            forResource: component.rawValue,
            withExtension: "mp3"
        ) else {
            print("MP3ファイルが見つかりません")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("再生エラー: \(error)")
        }
    }
}
