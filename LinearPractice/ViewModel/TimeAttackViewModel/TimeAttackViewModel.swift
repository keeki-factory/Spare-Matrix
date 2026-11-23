//
//  TimeAttackModel.swift
//  LinearPractice
//  
//  Created by keeki-fami on 2026/11/07
//  
//
import SwiftUI
import Combine
import AtCoderInSwift


enum TimeAttackPhase: Equatable {
    case choose
    case playing(PlayingPhase)
    case result
    case white
    
    var isNowPlaying: Bool {
        if self == TimeAttackPhase.playing(.playing(.fever)) || self == TimeAttackPhase.playing(.playing(.normal)){
            return true
        } else {
            return false
        }
    }
    
}
enum TimeAttackFeverPhase {
    case normal
    case fever
}

enum PlayingPhase: Equatable {
    case before
    case playing(TimeAttackFeverPhase)
    case done
}

@Observable
class TimeAttackViewModel: MatrixManager {
    var genProblemType: ProblemType = .add
    var nowPhase: TimeAttackPhase = .choose
    var timerTask: Task<Void, Never>?
    var isPushedBeforeState: Bool = false
    
    let gameTime = 60
    var remainingSeconds: CGFloat = 60.0
    var whiteOpacity = 0
//    var playingPhase: PlayingPhase = .before
    var showPauseButton: Bool = false
    
    var combo = 0
    var score = 0
    var feverPhase: TimeAttackFeverPhase = .normal
    
    var isBubble = false
    
    func setup() {
        remainingSeconds = CGFloat(gameTime)
        countdown = 3
        score = 0
        combo = 0
//        playingPhase = .before
    }
    
    var timeAttackLeaderboard: String {
        switch genProblemType {
        case .add:
            "com.LinearPractice.TimeAttack.add"
        case .sub:
            "com.LinearPractice.TimeAttack.sub"
        case .mul:
            "com.LinearPractice.TimeAttack.mul"
        default:
            ""
        }
    }
    
    var problemTypeName: String {
        switch genProblemType {
        case .add:
            "足し算"
        case .sub:
            "引き算"
        case .mul:
            "掛け算"
        default:
            ""
        }
    }
    
    var LocalRankingKey: String {
        switch genProblemType {
        case .add:
            "localAddRanking"
        case .sub:
            "localSubRanking"
        case .mul:
            "localMulRanking"
        default:
            ""
        }
    }
    
    var tintColor: Color {
        if feverPhase == .fever {
            Color.yellow
        } else {
            Color.blue
        }
    }
    
    var isFever: FeverModeType {
        if feverPhase == .fever {
            .dark
        } else {
            .light
        }
    }
    
    // 初期化時に問題を生成
    override func initGenerate(type: ProblemType? = nil) {
        super.initGenerate(type: genProblemType)
    }
    
    override func generate(type: ProblemType? = nil) {
        super.generate(type: genProblemType)
    }
    
    override func checkAnswer() async {
        await super.checkAnswer()
        if isAnswer {
            if let ans = Int(self.userInput) {
                var num = 0
                if genProblemType == .sub {
                    num = max(abs(ans), 3)
                } else if genProblemType == .mul {
                    num = max(abs(ans), 3)
                } else {
                    num = ans
                }
                
                SoundPlayer.shared.play(.problemCorrect)
                switch self.feverPhase {
                case .normal:
                    withAnimation {
                        self.combo += 1
                    }
                    self.score += num
                    if self.combo == 10 {
                        withAnimation {
                            self.feverPhase = .fever
                        }
                        self.isBubble.toggle()
                        manager.start()
                        self.feverStart()
                    }
                case .fever:
                    self.combo = 0
                    self.score += num*2
                }
            }
            
            self.userInput = ""
            
            if nowProblem == .problem1 {
                self.isSuccess1 = true
            } else {
                self.isSuccess2 = true
            }
            
            let haptics = UserDefaults.standard.bool(forKey: "isHaptics")
            print(haptics)
            if haptics {
                handleHaptics(.success)
            }
            
            // TODO: delayを入れる？
                try? await Task.sleep(nanoseconds: 200000000)
                withAnimation() {
                    self.nowProblem.toggle()
                } completion: {
                    if self.nowProblem == .problem1 {
                        self.isSuccess2 = false
                    } else {
                        self.isSuccess1 = false
                    }
                    
                    self.generate(type: self.genProblemType)
                }


        } else {
            let haptics = UserDefaults.standard.bool(forKey: "isHaptics")
            if haptics {
                handleHaptics(.error)
            }
            self.miniPhraseAnimation.toggle()
            checkAnimation.toggle()
            self.userInput = ""
            self.combo = 0
        }
    }
    
    var countdown = 3
    var countdownTimer: Timer?
    var gameTimer: AnyCancellable?
    
    enum whietOpacity: Int {
        case visible = 1
        case invisible = 0
        
        mutating func toggle() {
            switch self {
            case .visible:
                self = .invisible
            case .invisible:
                self = .visible
            }
        }
    }
    
    func moveWithWhiteSpace(after: TimeAttackPhase, white: @escaping () -> Void ) {
        withAnimation {
            nowPhase = .white
        } completion: {
            white()
            withAnimation {
                self.nowPhase = after
            }
        }
    }
    var result: ResultRanking = .init()
    // fever
    var remainingTime: Double = 10
    var isRunning = false
    let totalTime: Double = 10
    var timer: AnyCancellable?
    
}
