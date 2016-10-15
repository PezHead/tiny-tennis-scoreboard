//
//  Game.swift
//  Tiny Tennis
//
//  Created by David Bireta on 10/15/16.
//  Copyright © 2016 David Bireta. All rights reserved.
//

struct Game {
    
    // MARK:- Properties
    var redScore = 0
    var blueScore = 0
    
    var redPlayers = [Champion]()
    var bluePlayers = [Champion]()
    
    var currentServer: Champion {
        var server = firstServer
        var receiver = firstReceiver
        
        for total in 0...(redScore+blueScore) {
            if (total > 0 && total <= 20 && total % 2 == 0) || (total > 20) {
                let oldServer = server
                server = receiver
                receiver = oldServer
                
                if redPlayers.count == 2 {
                    // Swap
                    if receiver == redPlayers.first! {
                        receiver = redPlayers.last!
                    } else if receiver == redPlayers.last! {
                        receiver = redPlayers.first!
                    } else if receiver == bluePlayers.first {
                        receiver = bluePlayers.last!
                    } else if receiver == bluePlayers.last {
                        receiver = bluePlayers.first!
                    }
                }
            }
        }
        
        return server
    }
    
    var currentReceiver: Champion {
        var server = firstServer
        var receiver = firstReceiver
        
        for total in 0...(redScore+blueScore) {
            if (total > 0 && total <= 20 && total % 2 == 0) || (total > 20) {
                let oldServer = server
                server = receiver
                receiver = oldServer
                
                if redPlayers.count == 2 {
                    // Swap
                    if receiver == redPlayers.first! {
                        receiver = redPlayers.last!
                    } else if receiver == redPlayers.last! {
                        receiver = redPlayers.first!
                    } else if receiver == bluePlayers.first {
                        receiver = bluePlayers.last!
                    } else if receiver == bluePlayers.last {
                        receiver = bluePlayers.first!
                    }
                }
            }
        }
        
        return receiver
    }
    
    var winningTeam: Team? {
        if redScore >= 11 && (redScore - blueScore) >= 2 {
            return .red
        } else if blueScore >= 11 && (blueScore - redScore) >= 2 {
            return .blue
        } else {
            return nil
        }
    }
    
    // MARK: - Private Properties
    fileprivate var pointTracker = [Point]()
    fileprivate let firstServer: Champion
    fileprivate let firstReceiver: Champion
    fileprivate var firstServingTeam: Team {
        if redPlayers.contains(firstServer) {
            return .red
        } else {
            return .blue
        }
    }
    
    // MARK:- Public Methods
    init(firstServer: Champion, firstReceiver: Champion, redPlayers: [Champion], bluePlayers: [Champion]) {
        self.firstServer = firstServer
        self.firstReceiver = firstReceiver
        self.redPlayers = redPlayers
        self.bluePlayers = bluePlayers
    }
    
    mutating func addPoint(_ team: Team) {
        switch team {
        case .red:
            redScore += 1
            let pointWinner = redPlayers.contains(currentServer) ? currentServer : currentReceiver
            pointTracker.append(Point(server: currentServer, receiver: currentReceiver, winner: pointWinner))
        case .blue:
            blueScore += 1
            let pointWinner = bluePlayers.contains(currentServer) ? currentServer : currentReceiver
            pointTracker.append(Point(server: currentServer, receiver: currentReceiver, winner: pointWinner))
        }
    }
    
    mutating func subtractPoint(_ team: Team) {
        switch team {
        case .red:
            redScore -= 1
        case .blue:
            blueScore -= 1
        }
        
        pointTracker.removeLast()
    }
    
    mutating func undoPoint() {
        if let team = pointTracker.popLast() {
            if redPlayers.contains(team.winner) {
                redScore -= 1
            } else {
                blueScore -= 1
            }
        }
    }
}
