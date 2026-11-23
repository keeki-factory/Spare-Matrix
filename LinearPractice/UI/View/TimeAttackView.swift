//
//  TimeAttackView.swift
//  LinearPractice
//
//  Created by keeki-fami on 2026/11/04
//
//

import SwiftUI
import NumberPad
import PencilKit

struct TimeAttackView: View {
    @State private var timeAttackViewModel = TimeAttackViewModel()
    @State private var opacity: Double = 0
    
    var body: some View {
        Group {
            switch timeAttackViewModel.nowPhase {
            case .choose:
                TimeAttackChooseView(
                    opacity: $opacity,
                    timeAttackViewModel: timeAttackViewModel
                ) {
                }
            case .playing:
                TimeAttackPlayingView(
                    timeAttackViewModel: timeAttackViewModel,
                    opacity: $opacity
                )
                .onAppear() {
                    BGMPlayer.shared.fadeStop()
                }
            case .result:
                TimeAttackResultView(
                    timeAttackViewModel: timeAttackViewModel
                )
                .onAppear() {
                    SoundPlayer.shared.play(.resultAppear)
                }
            case .white:
                EmptyView()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            timeAttackViewModel.stop()
        }
    }
}

struct TimeAttackChooseView: View {
    @Binding var opacity: Double
    var timeAttackViewModel: TimeAttackViewModel
    let onStart: () -> Void
    // 連続タップ対策
    @State private var isTapped = false
    
    var body: some View {
        ZStack {
            GridBackground()
            
            VStack() {
                Rectangle()
                    .fill(.blue)
                    .frame(height: 80)
                    .overlay(alignment: .leading) {
                        Text("タイムアタック")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .padding(.leading, 32)
                    }
                
                Spacer()
                Button(action: {
                    if !isTapped {
                        isTapped = true
                        timeAttackViewModel.genProblemType = .add
                        print("addを渡してinitGenerateします。")
                        SoundPlayer.shared.play(.resultAppear)
                        timeAttackViewModel.initGenerate(type: .add)
                        timeAttackViewModel.moveWithWhiteSpace(after: .playing(.before), white: {})
                    }
                },label: {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [CardColor.timeattack.topColor, CardColor.timeattack.bottomColor],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .overlay {
                            VStack(spacing: 16) {
                                Text("足し算")
                                    .font(.title.bold())
                                Text("60秒でできるだけ多くの行列の足し算の計算問題を解こう！")
                                    .font(.body)
                                    .multilineTextAlignment(.center)
                            }
                            .foregroundStyle(.white)
                            .padding(24)
                        }
                })
                //                    .frame(maxWidth: 420)
                .frame(height: 150)
                .padding([.leading, .trailing], 30)
                
                Button(action: {
                    if !isTapped {
                        isTapped = true
                        timeAttackViewModel.genProblemType = .sub
                        SoundPlayer.shared.play(.resultAppear)
                        timeAttackViewModel.initGenerate(type: .sub)
                        timeAttackViewModel.moveWithWhiteSpace(after: .playing(.before), white: {})
                    }
                }, label: {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [CardColor.timeattack.topColor, CardColor.timeattack.bottomColor],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .overlay {
                            VStack(spacing: 16) {
                                Text("引き算")
                                    .font(.title.bold())
                                Text("60秒でできるだけ多くの行列の引き算の計算問題を解こう！")
                                    .font(.body)
                                    .multilineTextAlignment(.center)
                            }
                            .foregroundStyle(.white)
                            .padding(24)
                        }
                })
                //                    .frame(maxWidth: 420)
                .frame(height: 150)
                .padding([.leading, .trailing], 30)
                Button(action: {
                    if !isTapped {
                        isTapped = true
                        timeAttackViewModel.genProblemType = .mul
                        SoundPlayer.shared.play(.resultAppear)
                        timeAttackViewModel.initGenerate(type: .mul)
                        timeAttackViewModel.moveWithWhiteSpace(after: .playing(.before), white: {})
                    }
                }, label: {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [CardColor.timeattack.topColor, CardColor.timeattack.bottomColor],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .overlay {
                            VStack(spacing: 16) {
                                Text("掛け算")
                                    .font(.title.bold())
                                Text("60秒でできるだけ多くの行列の掛け算の計算問題を解こう！")
                                    .font(.body)
                                    .multilineTextAlignment(.center)
                            }
                            .foregroundStyle(.white)
                            .padding(24)
                        }
                })
                //                    .frame(maxWidth: 420)
                .frame(height: 150)
                .padding([.leading, .trailing], 30)
                
                
                Spacer()
            }
            //            .padding(.horizontal, 24)
        }
    }
}

struct TimeAttackPlayingBeforeView: View {
    var timeAttackViewModel: TimeAttackViewModel
    @Binding var isPushed: Bool
    var body: some View {
        VStack {
            if !isPushed {
                Text("画面をTapすると開始します。")
            } else {
                Text("\(timeAttackViewModel.countdown)")
            }
        }
    }
}

struct TimeAttackPlayingView: View {
    var timeAttackViewModel: TimeAttackViewModel
    @State private var memoView = PKCanvasView()
    @Binding var opacity: Double
    @State private var memoTool:MemoTool = .pencil
    @Environment(SettingViewModel.self) private var settingViewModel
    var memoButtonAlignment: Alignment {
        settingViewModel.selectedHand == .right ? .bottomTrailing : .bottomLeading
    }
    
    var body: some View {
        @Bindable var timeAttackViewModel = timeAttackViewModel
        ZStack {
            if timeAttackViewModel.feverPhase == .fever {
                Rectangle()
                    .fill(
                        LinearGradient(
                            stops: [
                                .init(color: Color(
                                    red: 2/255,
                                    green: 40/255,
                                    blue: 80/255
                                ), location: 0.0),
                                .init(color: Color(
                                    red: 0/255,
                                    green: 0/255,
                                    blue: 0/255
                                ), location: 0.5),
                                .init(color: Color(
                                    red: 0/255,
                                    green: 0/255,
                                    blue: 0/255
                                ), location: 1.0)
                            ],
                            startPoint: .top,
                            endPoint: .bottom)
                    )
            }
            BubbleBackgroundView(isActive: $timeAttackViewModel.isBubble)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            VStack(spacing: 0) {
                
                // bar
                if timeAttackViewModel.feverPhase == .fever {
                    VStack(spacing: 1) {
                        ProgressView(value: timeAttackViewModel.progress)
                            .frame(height: 50)
                            .padding([.leading, .trailing], 150)
                            .tint(timeAttackViewModel.tintColor)
                        Text("フィーバーまであと\(timeAttackViewModel.combo)/10問")
                            .font(.caption)
                            .opacity(0.5)
                    }
                } else {
                    VStack (spacing: 1) {
                        ProgressView(value: Double(timeAttackViewModel.combo)/10.0)
                            .frame(height: 50)
                            .padding([.leading, .trailing], 150)
                            .tint(timeAttackViewModel.tintColor)
                        Text("\(String(format: "%1f", timeAttackViewModel.remainingTime))")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.5))
                    }
                }
                
                // 画面上部
                Group {
                    switch timeAttackViewModel.nowPhase {
                    case .playing(.before):
                        TimeAttackPlayingBeforeView(
                            timeAttackViewModel: timeAttackViewModel,
                            isPushed: $timeAttackViewModel.isPushedBeforeState
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    default:
                        TimeAttackProblemView(timeAttackViewModel: timeAttackViewModel)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .overlay(alignment: .bottom) {
                    HStack {
                        Text("\(timeAttackViewModel.userInput.isEmpty ? "   " : timeAttackViewModel.userInput)")
                            .font(Font.title)
                            .background(Color(red: 217/255, green: 217/255, blue: 217/255))
                    }
                    .frame(maxWidth: .infinity, maxHeight: 40)
                    .padding()
                    .keyframeAnimator(initialValue: 0.0, trigger: timeAttackViewModel.checkAnimation) { content, value in
                        content.offset(x: value)
                    } keyframes: { _ in
                        KeyframeTrack {
                            MoveKeyframe(10.0)
                            LinearKeyframe(-10.0, duration: 0.1)
                            LinearKeyframe(5.0, duration: 0.1)
                            LinearKeyframe(-5.0, duration: 0.1)
                            LinearKeyframe(2.0, duration: 0.1)
                            LinearKeyframe(-2.0, duration: 0.1)
                            LinearKeyframe(1.0, duration: 0.1)
                            LinearKeyframe(-1.0, duration: 0.1)
                            LinearKeyframe(0.5, duration: 0.1)
                            LinearKeyframe(-0.5, duration: 0.1)
                        }
                        
                    }
                }
                .overlay(alignment: memoButtonAlignment) {
                    ZStack {
                        Button(action: {
                            
                        }, label: {
                            ZStack {
                                Rectangle()
                                    .fill(Color(red: 217/255, green: 217/255, blue: 217/255))
                                    .frame(width: 40, height: 40)
                                Image(systemName: timeAttackViewModel.isKeyboard ? "pencil.tip" : "plus.forwardslash.minus")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                            }
                        })
                        .buttonStyle(SubButtonStyle(onTouchUp: {
                            timeAttackViewModel.togglePadView()
                            if timeAttackViewModel.isKeyboard {
                                memoView.drawing = PKDrawing()
                            }
                        }))
                        .padding()
                        if timeAttackViewModel.nowPhase == .playing(.before) {
                            RoundedRectangle(cornerRadius: 5)
                                .fill(.black.opacity(0.5))
                                .frame(width: 41, height: 41
                                )
                                .padding()
                        }
                    }
                    
                }
                .overlay(alignment: .topLeading) {
                    Button(action: {
                        
                    }, label: {
                        ZStack {
                            Rectangle()
                                .fill(.red)
                                .frame(width: 40, height: 40)
                            Image(systemName: "stop.circle")
                                .resizable()
                                .scaledToFit()
                                .foregroundStyle(.white)
                                .frame(width: 20, height: 20)
                        }
                    })
                    .buttonStyle(SubButtonStyle(onTouchUp: {
                        timeAttackViewModel.showPauseButton = true
                    }))
                    .padding([.leading])
                    if timeAttackViewModel.nowPhase == .playing(.before) {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(.black.opacity(0.5))
                            .frame(width: 41, height: 41
                            )
                            .padding([.leading])
                    }
                }
                ZStack {
                    if timeAttackViewModel.isKeyboard {
                        NumberPadView("submit", text: $timeAttackViewModel.userInput, isHaptic: settingViewModel.isOn, action: {
                            Task {
                                await timeAttackViewModel.checkAnswer()
                            }
                        }, number: {
                            SoundPlayer.shared.play(.tap)
                        }, minus: {
                            SoundPlayer.shared.play(.tap)
                        }, backspace: {
                            SoundPlayer.shared.play(.tap)
                        })
                    } else {
                        MemoView(memoView: $memoView, isKeyboard: $timeAttackViewModel.isKeyboard)
                            .shadow(color: .gray.opacity(0.25), radius: 10, x: 0, y: -10)
                            .overlay(alignment: settingViewModel.selectedHand == .right ? .topTrailing : .topLeading) {
                                HStack {
                                    Button(action: {
                                        
                                    }, label: {
                                        ZStack {
                                            Rectangle()
                                                .fill(Color(red: 217/255, green: 217/255, blue: 217/255))
                                                .frame(width: 40, height: 40)
                                            Image(systemName: memoTool == .pencil ? "pencil" : "eraser.fill")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 20, height: 20)
                                        }
                                    })
                                    .buttonStyle(SubButtonStyle(onTouchUp: {
                                        SoundPlayer.shared.play(.tap)
                                        if memoTool == .eraser {
                                            memoView.tool = PKInkingTool(
                                                .pen,
                                                color: .black,
                                                width: 5
                                            )
                                            memoTool = .pencil
                                            print("現在はペンです")
                                        } else {
                                            memoView.tool = PKEraserTool(.vector)
                                            print("現在は消しゴムです")
                                            memoTool = .eraser
                                        }
                                    }))
                                    
                                    
                                    Button(action: {
                                        SoundPlayer.shared.play(.tap)
                                        memoView.drawing = PKDrawing()
                                    }, label: {
                                        ZStack {
                                            Rectangle()
                                                .fill(.red)
                                                .frame(width: 40, height: 40)
                                            Image(systemName: "trash")
                                                .resizable()
                                                .scaledToFit()
                                                .foregroundStyle(Color.white)
                                                .frame(width: 20, height: 20)
                                        }
                                    })
                                    .buttonStyle(SubButtonStyle(onTouchUp: {
                                        memoView.drawing = PKDrawing()
                                    }))
                                }
                                .padding()
                            }
                    }
                    
                    if timeAttackViewModel.nowPhase == .playing(.before) {
                        Rectangle()
                            .fill(.black.opacity(0.5))
                            .ignoresSafeArea()
                    }
                }
                
            }
            .overlay(alignment: .topLeading) {
                Text("Score \(timeAttackViewModel.score)")
                    .font(.headline)
                //                        .foregroundStyle(timeAttackViewModel.nowBackgroundPhase == .phase1 ? .black : .white)
                    .padding()
                    .foregroundStyle(timeAttackViewModel.feverPhase == .fever ? .white : .black)
            }
            .overlay(alignment: .topTrailing) {
                Text("残り \(String(format: "%.1f", timeAttackViewModel.remainingSeconds)) 秒")
                    .font(.headline)
                //                        .foregroundStyle(timeAttackViewModel.nowBackgroundPhase == .phase1 ? .black : .white)
                    .padding()
                    .foregroundStyle(timeAttackViewModel.feverPhase == .fever ? .white : .black)
            }
            
            if timeAttackViewModel.nowPhase == .playing(.done) {
                Rectangle()
                    .fill(.black.opacity(0.5))
                    .overlay() {
                        Text("終了！")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                    }
                    .ignoresSafeArea()
            }
            
            if (timeAttackViewModel.nowPhase.isNowPlaying) && timeAttackViewModel.showPauseButton {
                ZStack {
                    Rectangle()
                        .fill(.black.opacity(0.5))
                        .ignoresSafeArea()
                    GeometryReader {geometry in
                        VStack {
                            Text("Pause")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                            VStack {
                                Button(action: {}, label: {
                                    ZStack {
                                        Rectangle()
                                            .fill(Color(red: 217/255, green: 217/255, blue: 217/255))
                                            .frame(width: geometry.size.width*0.6, height: geometry.size.height*0.05)
                                        Text("再挑戦する")
                                    }
                                })
                                    .buttonStyle(SubButtonStyle(onTouchUp: {
                                        timeAttackViewModel.restart()
                                    }))
                                
                                Button(action: {}, label: {
                                    ZStack {
                                        Rectangle()
                                            .fill(Color(red: 217/255, green: 217/255, blue: 217/255))
                                            .frame(width: geometry.size.width*0.6, height: geometry.size.height*0.05)
                                        Text("やめる")
                                    }
                                })
                                    .buttonStyle(SubButtonStyle(onTouchUp: {
                                        
                                            timeAttackViewModel.pauseQuit()
                                        
                                    }))
                                Button(action: { }, label: {
                                    ZStack {
                                        Rectangle()
                                            .fill(Color(red: 217/255, green: 217/255, blue: 217/255))
                                            .frame(width: geometry.size.width*0.6, height: geometry.size.height*0.05)
                                        Text("Pause画面を閉じる")
                                    }
                                })
                                    .buttonStyle(SubButtonStyle(onTouchUp: {
                                        timeAttackViewModel.backToGame()
                                    }))
                            }
                            .frame(width: geometry.size.width*0.8, height: geometry.size.height/3)
                            .background {
                                Color.white
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .overlay() {
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color(red: 217/255, green: 217/255, blue: 217/255), lineWidth: 3)
                            }
                        }
                        .frame(width: geometry.size.width, height: geometry.size.height)
                    }
                }
            }
            
            // .playing(.before)かつ、isPushedBeforeStateでおされてない場合
            if timeAttackViewModel.nowPhase == .playing(.before) && !timeAttackViewModel.isPushedBeforeState {
                Button(action:{
                    SoundPlayer.shared.play(.countdown)
                    timeAttackViewModel.start_count()
                    timeAttackViewModel.isPushedBeforeState = true
                }, label: {
                    Rectangle()
                        .fill(.clear)
                })
            }
            
        }
        .onAppear() {
            if opacity == 1 {
                withAnimation {
                    opacity = 0
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        
    }
}

struct TimeAttackResultView: View {
    var timeAttackViewModel: TimeAttackViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            GridBackground()
            
            VStack(spacing: 24) {
                Rectangle()
                    .fill(.blue)
                    .frame(height: 80)
                    .overlay(alignment: .leading) {
                        Text("結果")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .padding(.leading, 32)
                    }
                
                Spacer()
                
                Text("score")
                    .font(.system(size: 24, weight: .bold))
                Text("\(timeAttackViewModel.score)")
                    .font(.system(size: 72, weight: .bold,
                                  design: .rounded))
                    .tracking(5)
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(red: 242/255, green: 244/255, blue: 245/255))
                    .overlay() {
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(.blue, lineWidth: 1)
                    }
                    .frame(height: 200)
                    .padding([.leading, .trailing], 60)
                    .overlay() {
                        VStack(spacing: 8) {
                            ForEach(0..<timeAttackViewModel.result.ranking.count) { i in
                                Text("\(i+1)位 - \(timeAttackViewModel.result.ranking[i])")
                                    .background(
                                        i == timeAttackViewModel.result.idx ? Color.yellow : Color.clear
                                    )
                            }
                        }
                    }
                Button("Xでスコアを共有") {
                    SoundPlayer.shared.play(.tap)
                    shareOnTwitter(correctCount: timeAttackViewModel.score)
                }
                Button("ランキングを確認") {
                    SoundPlayer.shared.play(.tap)
                    GameCenterManager.shared.showLeaderboards()
                }
                Button("ホームに戻る") {
                    SoundPlayer.shared.play(.tap)
                    timeAttackViewModel.sendToLeaderboard()
                    dismiss()
                }
                Button("もう一度やる") {
                    timeAttackViewModel.sendToLeaderboard()
                    timeAttackViewModel.restart()
                }
                
                Spacer()
                
                AdBannerView()
                    .frame(width: 370, height: 50)
            }
            .onAppear() {
                timeAttackViewModel.sendToLeaderboard()
                timeAttackViewModel.setLocalRanking()
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    func shareOnTwitter(correctCount: Int) {
        let text = String("✨行列計算 タイムアタックチャレンジ✨ \n\n \(timeAttackViewModel.problemTypeName)部門：score \(correctCount)\n\nアプリ「隙間時間で行列計算」を今すぐインストール\n\nhttps://apps.apple.com/jp/app/%E7%84%A1%E9%99%90%E8%A1%8C%E5%88%97%E8%A8%88%E7%AE%97/id6785983550")
        let encodedText = text.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        
        if let encodedText = encodedText, let url = URL(string: "https://x.com/compose/post?text=\(encodedText)") {
            UIApplication.shared.open(url)
        }
    }
}

#Preview {
    TimeAttackView()
}
#Preview {
    @Previewable @State var timeAttackViewModel = TimeAttackViewModel()
    TimeAttackResultView(timeAttackViewModel: timeAttackViewModel)
}

