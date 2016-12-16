//
//  Match.swift
//  TableTennisAPI
//
//  Created by David Bireta on 12/13/16.
//  Copyright © 2016 David Bireta. All rights reserved.
//

public struct Match {
    public let winner: String
    public let loser: String
    public let date: String
    public let games: [Game]
    
    public init?(jsonData: [String:Any]) {
        guard let winner = jsonData["winner"] as? String,
            let loser = jsonData["loser"] as? String,
            let date = jsonData["startTime"] as? String,
            let games = jsonData["games"] as? [Any]
            else { return nil }
        
        self.winner = winner
        self.loser = loser
        self.date = date
        
        var allGames = [Game]()
        for case let game as [String:Any] in games {
            if let g = Game(jsonData: game) {
                allGames.append(g)
            }
        }
        self.games = allGames
    }
    
    public func gameSummary() -> String {
        var result = [String]()
        
        for game in games {
            if game.winner == winner {
                result.append("\(game.winningScore)-\(game.losingScore)")
            } else {
                result.append("\(game.losingScore)-\(game.winningScore)")
            }
        }
        
        return result.joined(separator: ", ")
    }
}
