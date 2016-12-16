//
//  Game.swift
//  TableTennisAPI
//
//  Created by David Bireta on 12/15/16.
//  Copyright © 2016 David Bireta. All rights reserved.
//

public struct Game {
    public let winner: String
    public let loser: String
    public let winningScore: Int
    public let losingScore: Int
    
    public init?(jsonData: [String:Any]) {
        guard let winner = jsonData["winner"] as? String,
            let loser = jsonData["loser"] as? String,
            let winningScore = jsonData["winningScore"] as? Int,
            let losingScore = jsonData["losingScore"] as? Int
            else { return nil }
        
        self.winner = winner
        self.loser = loser
        self.winningScore = winningScore
        self.losingScore = losingScore
    }
}
