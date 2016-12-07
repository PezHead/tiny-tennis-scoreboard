//
//  Announcer.swift
//  Tiny Tennis
//
//  Created by David Bireta on 10/15/16.
//  Copyright © 2016 David Bireta. All rights reserved.
//

import AVFoundation


/// Singleton to manage any spoken announcements, such as score, serving, etc.
/// Yep, it is a singleton.
class Announcer {
    typealias Seconds = TimeInterval
    
    static let shared = Announcer()
    open var isMuted = false
    
    fileprivate let audioPlayer: AVAudioPlayer
    fileprivate let synthesizer = AVSpeechSynthesizer()
    
    fileprivate init() {
        if let blip = NSDataAsset(name: "PointBlip") {
            do {
                try audioPlayer = AVAudioPlayer(data: blip.data, fileTypeHint: AVFileTypeWAVE)
                audioPlayer.prepareToPlay()
            } catch {
                print("ERROR: Error intializing 'PointBlip' sound")
                
                // Satisfy initializer
                audioPlayer = AVAudioPlayer()
            }
        } else {
            // Satisfy initializer
            audioPlayer = AVAudioPlayer()
        }
    }
    
    fileprivate func say(_ message: String, withDelay delay: Seconds = 0) {
        // Cut off any in-progress announcements
        synthesizer.stopSpeaking(at: .immediate)
        
        // Say message with optional delay
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            let utterance = AVSpeechUtterance(string: message)
            utterance.pitchMultiplier = 1.0
            utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
            
            self.synthesizer.speak(utterance)
        }
    }
    
    // MARK: - Public Methods
    func playPointSound() {
        audioPlayer.play()
    }
    
    // If a game is in progress, this would be something like "Five serving three"
    // If it is the start of a game, more like "Game three. Service Bireta" (or  "Game three. Bireta serving Niebling" for doubles).
    //
    // For "deuce" situations (both players >= 10)
    // "Deuce"
    // "Advantage, Bireta"
    func announceScore(withMatch match: Match) {
        guard isMuted == false else { return }
        
        guard let game = match.currentGame else { return }
        
        let servingScore = match.redTeam.contains(game.currentServer) ? game.redScore : game.blueScore
        let receivingScore = match.redTeam.contains(game.currentReceiver) ? game.redScore : game.blueScore
        
        // Don't announce the final point of a game.
        if (servingScore >= 11 && servingScore - receivingScore >= 2) || (receivingScore >= 11 && receivingScore - servingScore >= 2) { return }
    
        if game.redScore >= 10 && game.blueScore >= 10 {
            // Don't announce the score when in 'deuce mode'
            if game.redScore == game.blueScore {
                say("Deuce", withDelay: 0.5)
            } else {
                let adPlayers = servingScore > receivingScore ? game.currentServer.phoeneticName : game.currentReceiver.phoeneticName
                say("Advantage, \(adPlayers)", withDelay: 0.5)
            }
        } else if game.redScore == 0 && game.blueScore == 0 {
            if match.type == .singles {
                say("Game \(match.gameCount)... Service \(game.currentServer.phoeneticName)")
            } else if match.type == .doubles {
                say("Game \(match.gameCount)... \(game.currentServer.phoeneticName) serving \(game.currentReceiver.phoeneticName)")
            }
        } else {
            let mpSuffix = match.isMatchPoint ? "Match point!" : ""
            say("\(servingScore) serving \(receivingScore). \(mpSuffix)", withDelay: 0.5)
        }
    }
    
    // Game: "Game, Bireta"
    // Match: "Match, Bireta. 11, 8. 11, 7. 4, 11. 11, 9"
    func announceGameWinner(withMatch match: Match) {
        guard let players = match.gameWinningPlayerNames else { return }
        
        var winType: String
        if match.redWins == 3 || match.blueWins == 3 {
            winType = "Match"
        } else {
            winType = "Game"
        }
        
        say("\(winType)........ \(players)", withDelay: 0.5)
    }
    
    func announceMatchStart(_ match: Match) {
        let redTeamNames = match.redTeam.map { $0.phoeneticName }.joined(separator: " and ")
        let blueTeamNames = match.blueTeam.map { $0.phoeneticName }.joined(separator: " and ")
        
        let openingLines = [
            "It's a brilliant afternoon for some tiny tennis! Today's matchup",
            "Now stepping onto the court",
            "This is the match-up we've all been waiting for.",
            "Welcome to Center Court at media fly ..... We've got a smashing matchup this afternoon."
        ]
        
        let random = Int(arc4random_uniform(UInt32(openingLines.count)))
        let line = openingLines[random]
        say("\(line); \(redTeamNames), versus \(blueTeamNames)")
    }
}

