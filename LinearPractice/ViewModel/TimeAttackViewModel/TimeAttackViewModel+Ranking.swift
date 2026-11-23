//
//  TimeAttackViewModel+imRanking.swift
//  LinearPractice
//  
//  Created by keeki-fami on 2026/11/23
//  
//
import SwiftUI

// Ranking
extension TimeAttackViewModel {
    
    // ranking data model for result view
    struct ResultRanking {
        var ranking = [0,0,0,0,0]
        var idx = 5
    }
    
    // update ranking being stored on device.
    func setLocalRanking() {
        do {
            let data = UserDefaults.standard.data(forKey: self.LocalRankingKey)
            if data == nil {
                // データを5つ作る
                var ranking = [0, 0, 0, 0, 0]
                let idx = binarySearch(arr: ranking, num: self.score)
                ranking.append(self.score)
                ranking.sort(by: {$0 > $1})
                
                result.ranking = ranking
                result.idx = idx
                
                let encodeData = try JSONEncoder().encode(ranking)
                UserDefaults.standard.set(encodeData, forKey: self.LocalRankingKey)
            } else {
                var ranking = try JSONDecoder().decode([Int].self, from: data!)
                ranking.sort(by: {$0 > $1})
                let idx = binarySearch(arr: ranking, num: self.score)
                ranking.append(self.score)
                ranking.sort(by: {$0 > $1})
                
                result.ranking = ranking
                result.idx = idx
                print("idx: \(idx)")
                
                if ranking.count > 5 {
                    let len = ranking.count
                    ranking.removeLast(len - 5)
                }
                
                let encodeData = try JSONEncoder().encode(ranking)
                UserDefaults.standard.set(encodeData, forKey: self.LocalRankingKey)
            }
        } catch {
            print("error")
        }
    }
    
    func binarySearch(arr: [Int], num: Int) -> Int {
        var l = -1
        var r = arr.count
        while (l+1<r) {
            var middle = (l+r)/2
            if arr[middle] > num {
                l = middle
            } else if arr[middle] <= num {
                r = middle
            } else {
                return middle
            }
        }
        return r
    }
    
    // send score to Leaderboard
    func sendToLeaderboard() {
        print("send to timeAttackLeaderboard: \(timeAttackLeaderboard)")
        GameCenterManager.shared.submitScore(self.score, to: timeAttackLeaderboard)
    }
}
