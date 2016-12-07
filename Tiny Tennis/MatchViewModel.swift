//
//  MatchViewModel.swift
//  Tiny Tennis
//
//  Created by David Bireta on 10/15/16.
//  Copyright © 2016 David Bireta. All rights reserved.
//

import UIKit

enum Side {
    case left
    case right
}

let red = Chameleon.color(withHexString: "#56D1D2")
let blue = Chameleon.color(withHexString: "#AEE283")

struct MatchViewModel {
    
    // MARK:- Properties
    var delegate: MatchViewModelDelegate?
    
    var leftScore: String {
        if !warmupEnded {
            return "WARM"
        }
        
        guard let game = match.currentGame else { return "XX" }
        return leftSideTeam == .red ? "\(game.redScore)" : "\(game.blueScore)"
    }
    var leftColor: UIColor {
        guard match.startTime != nil else { return UIColor.darkGray }
        //        return leftSideTeam == .red ? red : blue
        return red!
    }
    var leftAvatar: UIImage? {
        guard match.startTime != nil else { return nil }
        return leftSideTeam == .red ? match.redTeam.first?.avatarImage : match.blueTeam.first?.avatarImage
    }
    
    var leftPartnerAvatar: UIImage? {
        guard match.startTime != nil else { return nil }
        return leftSideTeam == .red ? match.redTeam.last?.avatarImage : match.blueTeam.last?.avatarImage
    }
    
    var leftChampionName: String? {
        guard match.startTime != nil else { return "Red Champion" }
        return leftSideTeam == .red ? match.redTeam.first?.name : match.blueTeam.first?.name
    }
    
    var leftChampionPartnerName: String? {
        guard match.startTime != nil else { return "Red Champion" }
        return leftSideTeam == .red ? match.redTeam.last?.name : match.blueTeam.last?.name
    }
    
    var rightChampionName: String? {
        guard match.startTime != nil else { return "Blue Champion" }
        return leftSideTeam == .red ? match.blueTeam.first?.name : match.redTeam.first?.name
    }
    
    var rightChampionPartnerName: String? {
        guard match.startTime != nil else { return "Blue Champion" }
        return leftSideTeam == .red ? match.blueTeam.last?.name : match.redTeam.last?.name
    }
    
    
    var leftWins: Int {
        guard match.startTime != nil else { return 0 }
        return leftSideTeam == .red ? match.redWins : match.blueWins
    }
    
    var leftServing: String {
        guard let game = match.currentGame else { return "." }
        guard let first = game.redPlayers.first else { return "." }
        guard let fBlue = game.bluePlayers.first else { return "." }
        
        if leftSideTeam == .red && game.currentServer == first {
            return "SERVE"
        }
        else if leftSideTeam == .red && game.currentReceiver == first && match.type == .doubles {
            return "REC"
        } else if leftSideTeam == .blue && game.currentServer == fBlue {
            return "SERVE"
        } else if leftSideTeam == .blue && game.currentReceiver == fBlue && match.type == .doubles {
            return "REC"
        }
        
        return "."
    }
    
    var leftPartnerServing: String {
        guard let game = match.currentGame else { return "." }
        guard let first = game.redPlayers.last else { return "." }
        guard let lBlue = game.bluePlayers.last else { return "." }
        
        if leftSideTeam == .red && game.currentServer == first {
            return "SERVE"
        }
        else if leftSideTeam == .red && game.currentReceiver == first {
            return "REC"
        } else if leftSideTeam == .blue && game.currentServer == lBlue {
            return "SERVE"
        } else if leftSideTeam == .blue && game.currentReceiver == lBlue {
            return "REC"
        }
        
        return "."
    }
    
    var rightServing: String {
        guard let game = match.currentGame else { return "." }
        guard let first = game.redPlayers.first else { return "." }
        guard let fBlue = game.bluePlayers.first else { return "." }
        
        if leftSideTeam == .blue && game.currentServer == first {
            return "SERVE"
        }
        else if leftSideTeam == .blue && game.currentReceiver == first && match.type == .doubles {
            return "REC"
        } else if leftSideTeam == .red && game.currentServer == fBlue {
            return "SERVE"
        } else if leftSideTeam == .red && game.currentReceiver == fBlue && match.type == .doubles {
            return "REC"
        }
        
        return "."
    }
    
    var rightPartnerServing: String {
        guard let game = match.currentGame else { return "." }
        guard let first = game.redPlayers.last else { return "." }
        guard let lBlue = game.bluePlayers.last else { return "." }
        
        if leftSideTeam == .blue && game.currentServer == first {
            return "SERVE"
        }
        else if leftSideTeam == .blue && game.currentReceiver == first {
            return "REC"
        } else if leftSideTeam == .red && game.currentServer == lBlue {
            return "SERVE"
        } else if leftSideTeam == .red && game.currentReceiver == lBlue {
            return "REC"
        }
        
        return "."
    }
    
    var rightScore: String {
        if !warmupEnded {
            return " UP     "
        }
        
        guard let game = match.currentGame else { return "XX" }
        return leftSideTeam == .red ? "\(game.blueScore)" : "\(game.redScore)"
    }
    var rightColor: UIColor {
        guard match.startTime != nil else { return UIColor.darkGray }
        //        return leftSideTeam == .red ? blue : red
        return blue!
    }
    
    var rightAvatar: UIImage? {
        guard match.startTime != nil else { return nil }
        return leftSideTeam == .red ? match.blueTeam.first?.avatarImage : match.redTeam.first?.avatarImage
    }
    
    var rightPartnerAvatar: UIImage? {
        guard match.startTime != nil else { return nil }
        return leftSideTeam == .red ? match.blueTeam.last?.avatarImage : match.redTeam.last?.avatarImage
    }
    
    var rightWins: Int {
        guard match.startTime != nil else { return 0 }
        return leftSideTeam == .red ? match.blueWins : match.redWins
    }
    
    
    var durationDesription: String {
        guard let start = match.startTime else { return "TAP TO BEGIN MATCH" }
        
        let elapsedSeconds = Date().timeIntervalSince(start as Date)
        let min = Int(elapsedSeconds / 60)
        let units = (min == 1) ? "minute" : "minutes"
        return "Match Duration: \(min) \(units)"
    }
    
    var isSingles: Bool {
        return match.type == .singles
    }
    
    // FIXME: I don't like this here
    // Also better renamed winningGamePlayers
    var winningPlayerNames: String? {
        return match.gameWinningPlayerNames
    }
    
    // FIXME: Better renamed winning Match champions
    var winningChampions: [Champion]? {
        return match.matchWinningChampions
    }
    
    // FIXME: Um........ wtf
    var victoryMatch: Match {
        return match
    }
    
    // Private properties
    fileprivate var match = Match()
    fileprivate var leftSideTeam: Team = .red
    fileprivate var warmupEnded = false
    
    
    // MARK: - Public Methods
    init() {
        print("viewModel: init")
    }
    
    mutating func startMatch() {
        match.delegate = self
        
        match.startMatch()
        delegate?.didUpdateProperty()
        
        Announcer.shared.announceMatchStart(match)
    }
    
    mutating func resetMatch() {
        match.resetMatch()
        delegate?.didUpdateProperty()
    }
    
    mutating func confirmGameFinished() {
        match.confirmGameOver()
        
        leftSideTeam = leftSideTeam == .red ? .blue : .red
        delegate?.didUpdateProperty()
        
        // Don't announce new game if match is over
        if match.endTime == nil {
            Announcer.shared.announceScore(withMatch: match)
        }
    }
    
    mutating func addPointFor(_ side: Side) {
        guard match.startTime != nil else { return }
        
        // The first registered input should switch from "warmup" to starting the match.
        if !warmupEnded {
            warmupEnded = true
            
            // FIXME: A bit of a sledge hammer in order to reset the game duration value.
            // Better would be to not have this actually start counting until the warmup is finished.
            match.resetGameDuration()
            
            delegate?.didUpdateProperty()
            Announcer.shared.announceScore(withMatch: match)
            
            return
        }
        
        if (side == .left && leftSideTeam == .red) || (side == .right && leftSideTeam == .blue) {
            match.addPoint(.red)
        } else {
            match.addPoint(.blue)
        }
        
        delegate?.didUpdateProperty()
        
        Announcer.shared.playPointSound()
        Announcer.shared.announceScore(withMatch: match)
    }
    
    mutating func subtractPointFor(_ side: Side) {
        guard match.startTime != nil else { return }
        
        if (side == .left && leftSideTeam == .red) || (side == .right && leftSideTeam == .blue) {
            match.subtractPoint(.red)
        } else {
            match.subtractPoint(.blue)
        }
        
        delegate?.didUpdateProperty()
    }
    
    mutating func undoLastPoint() {
        if (match.currentGame?.redScore == 0 && match.currentGame?.blueScore == 0 && match.gameCount > 1) {
            // Rewind to the previous game, removing the last point
            match.removeCurrentGame()
            leftSideTeam = leftSideTeam == .red ? .blue : .red
        }
        
        match.erasePoint()
    }
    
    mutating func setChampions(_ champions: [Champion], forSide side: Side) {
        if (side == .left && leftSideTeam == .red) || (side == .right && leftSideTeam == .blue) {
            match.redTeam = champions
        } else {
            match.blueTeam = champions
        }
        
        delegate?.didUpdateProperty()
    }
    
    mutating func toggleInitialServer() {
        guard match.gameCount == 1 && match.currentGame?.redScore == 0 && match.currentGame?.blueScore == 0 else {
            print("Can't alter server after match has started")
            return
        }
        
        match.toggleServer()
    }
}

// MARK: - MatchViewModelDelegate Protocol
protocol MatchViewModelDelegate {
    func didUpdateProperty()
    func confirmGameWonBy(_ winningTeam: Team)
}

// MARK:- MatchDelegate
extension MatchViewModel: MatchDelegate {
    mutating func didDetectGameOverForTeam(_ team: Team) {
        delegate?.confirmGameWonBy(team)
    }
    
    func didUpdateScore() {
        delegate?.didUpdateProperty()
    }
}
