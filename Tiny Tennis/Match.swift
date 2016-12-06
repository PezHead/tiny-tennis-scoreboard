//
//  Match.swift
//  Tiny Tennis
//
//  Created by David Bireta on 10/15/16.
//  Copyright © 2016 David Bireta. All rights reserved.
//

enum Team {
    case red
    case blue
}

enum MatchType {
    case singles
    case doubles
}

protocol MatchDelegate {
    mutating func didDetectGameOverForTeam(_ team: Team)
    func didUpdateScore()
}

// Slack response for chat.postMessage, needed for subsequent calls to chat.update
var slack_ts = ""
var slack_channelID = ""


class Match {
    
    // MARK:- Properties
    var delegate: MatchDelegate?
    
    var redTeam = [Champion]()
    var blueTeam = [Champion]()
    var gameCount: Int {
        return games.count
    }
    
    fileprivate (set) var startTime: Date?
    fileprivate (set) var endTime: Date?
    var type: MatchType {
        return (redTeam.count == 1 && blueTeam.count == 1) ? .singles : .doubles
    }
    var redWins: Int {
        var total = 0
        for game in games {
            if game.winningTeam == .red {
                total += 1
            }
        }
        return total
    }
    var blueWins: Int {
        var total = 0
        for game in games {
            if game.winningTeam == .blue {
                total += 1
            }
        }
        return total
    }
    
    var currentGame: Game? {
        get {
            if games.isEmpty {
                return nil
            }
            
            return games[games.endIndex-1]
        }
        set {
            if let game = newValue {
                if games.isEmpty {
                    games.append(game)
                } else {
                    games[games.endIndex - 1] = game
                }
            } else {
                games.removeLast()
            }
        }
    }
    
    var isMatchPoint: Bool {
        guard redWins == 2 || blueWins == 2 else { return false }
        
        if let game = currentGame {
            guard game.redScore >= 10 || game.blueScore >= 10 else { return false }
            
            if redWins == 2 && game.redScore >= 10 && (game.redScore > game.blueScore) {
                return true
            }
            
            if blueWins == 2 && game.blueScore >= 10 && (game.blueScore > game.redScore) {
                return true
            }
        }
        
        return false
    }
    
    // MARK: - Private Properteis
    fileprivate var games = [Game]()
    fileprivate var initialFirstServe: Team?
    
    
    // MARK:- Public Methods
    func startMatch() {
        // Ensure we are in a clean state
        resetMatch()
        
        startTime = Date()
        
        let random = arc4random_uniform(2)
        if random == 0 {
            currentGame = Game(firstServer: redTeam.first!, firstReceiver: blueTeam.first!, redPlayers: redTeam, bluePlayers: blueTeam)
            initialFirstServe = .red
        } else {
            currentGame = Game(firstServer: blueTeam.first!, firstReceiver: redTeam.first!, redPlayers: redTeam, bluePlayers: blueTeam)
            initialFirstServe = .blue
        }
        
        delegate?.didUpdateScore()  // Should this be didBeginmatch??
        
        postMatchStartToSlack()
    }
    
    func toggleServer() {
        if initialFirstServe == .blue {
            currentGame = Game(firstServer: redTeam.first!, firstReceiver: blueTeam.first!, redPlayers: redTeam, bluePlayers: blueTeam)
            initialFirstServe = .red
        } else {
            currentGame = Game(firstServer: blueTeam.first!, firstReceiver: redTeam.first!, redPlayers: redTeam, bluePlayers: blueTeam)
            initialFirstServe = .blue
        }
        
        delegate?.didUpdateScore()
    }
    
    func addPoint(_ team: Team) {
        currentGame?.addPoint(team)
        
        if let team = currentGame?.winningTeam {
            delegate?.didDetectGameOverForTeam(team)
            delegate?.didUpdateScore()
        }
        
        updateGameScoreToSlack()
    }
    
    // TODO: remove this
    func subtractPoint(_ team: Team) {
        currentGame?.subtractPoint(team)
        delegate?.didUpdateScore()
    }
    
    func erasePoint() {
        currentGame?.undoPoint()
        delegate?.didUpdateScore()
        
        updateGameScoreToSlack()
    }
    
    func removeCurrentGame() {
        games.removeLast()
        delegate?.didUpdateScore()
    }
    
    func resetMatch() {
        startTime = nil
        games.removeAll()
        
        // Hmm, does the Match object really need a delegate anymore???
        delegate?.didUpdateScore()
    }
    
    var gameWinningPlayerNames: String? {
        guard let team = currentGame?.winningTeam else { return nil }
        
        if team == .red {
            let names = redTeam.map { $0.phoeneticName }
            return names.joined(separator: ". ")
        } else {
            let names = blueTeam.map { $0.phoeneticName }
            return names.joined(separator: ". ")
        }
    }
    
    var matchWinningChampions: [Champion]? {
        guard redWins == 3 || blueWins == 3 else { return nil }
        
        if redWins == 3 {
            return redTeam
        } else {
            return blueTeam
        }
    }
    
    /// Create a game summary
    var scoreSummary: String {
        guard redWins == 3 || blueWins == 3 else {
            print("scoreSummary() is only valid for a completed match.")
            return "<VOID>"
        }
        
        var team = Team.red
        if blueWins == 3 {
            team = .blue
        }
        
        var scores = [String]()
        for game in games {
            
            if team == .red {
                if game.redScore > game.blueScore {
                    scores.append("*\(game.redScore)-\(game.blueScore)*")
                } else {
                    scores.append("\(game.redScore)-\(game.blueScore)")
                }
            } else {
                if game.blueScore > game.redScore {
                    scores.append("*\(game.blueScore)-\(game.redScore)*")
                } else {
                    scores.append("\(game.blueScore)-\(game.redScore)")
                }
            }
        }
        
        let gameSummary = scores.joined(separator: ", ")
        return gameSummary
    }
    
    func confirmGameOver() {
        updateGameScoreToSlack()
        
        // Test printing message
        let teamName = currentGame?.winningTeam == .red ? "Red" : "Blue"
        let winScore = currentGame?.winningTeam == .red ? currentGame?.redScore : currentGame?.blueScore
        let loseScore = currentGame?.winningTeam == .red ? currentGame?.blueScore : currentGame?.redScore
        print("Game \(games.count) was won by \(teamName): \(winScore)-\(loseScore)")
        
        if checkForFinishedMatch((currentGame?.winningTeam)!) {
            return
        }
        
        //
        // Determine Next Server
        //
        
        // Odd games have initialServingTeam
        // If singles, always return first
        if type == .singles {
            if (games.count % 2 == 0 && initialFirstServe == .red) || (games.count % 2 == 1 && initialFirstServe == .blue) {
                let newGame = Game(firstServer: redTeam.first!, firstReceiver: blueTeam.first!, redPlayers: redTeam, bluePlayers: blueTeam)
                games.append(newGame)
            } else {
                let newGame = Game(firstServer: blueTeam.first!, firstReceiver: redTeam.first!, redPlayers: redTeam, bluePlayers: blueTeam)
                games.append(newGame)
            }
        } else {
            // Doubles
            let firstTeam = initialFirstServe == .red ? redTeam : blueTeam
            let secondTeam = initialFirstServe == .red ? blueTeam : redTeam
            
            // Game 1 & 5 == initial server
            if games.count == 0 || games.count == 4 {
                let newGame = Game(firstServer: firstTeam.first!, firstReceiver: secondTeam.first!, redPlayers: redTeam, bluePlayers: blueTeam)
                games.append(newGame)
            }
                
                // Game 2 == initial receiver
            else if games.count == 1 {
                let newGame = Game(firstServer: secondTeam.first!, firstReceiver: firstTeam.first!, redPlayers: redTeam, bluePlayers: blueTeam)
                games.append(newGame)
            }
                
                // Game 3 == initial server partner
            else if games.count == 2 {
                let newGame = Game(firstServer: firstTeam.last!, firstReceiver: secondTeam.last!, redPlayers: redTeam, bluePlayers: blueTeam)
                games.append(newGame)
            }
                
                // Game 4 == initial receiver partner
            else if games.count == 3 {
                let newGame = Game(firstServer: secondTeam.last!, firstReceiver: firstTeam.last!, redPlayers: redTeam, bluePlayers: blueTeam)
                games.append(newGame)
            }
        }
        
        
        delegate?.didUpdateScore()  // Again, something like didStartNewGame??
    }
    
    func resetGameDuration() {
        startTime = Date()
    }
}


// MARK:- Private Methods
private extension Match {
    func checkForFinishedMatch(_ team: Team) -> Bool {
        if (team == .red && redWins == 3) || (team == .blue && blueWins == 3) {
            print("Match victory for \(team)")
            endTime = Date()
            
            let winningTeam = team == .red ? redTeam.map{$0.name}.joined(separator: "/") : blueTeam.map{$0.name}.joined(separator: "/")
            let losingTeam = team == .red ? blueTeam.map{$0.name}.joined(separator: "/") : redTeam.map{$0.name}.joined(separator: "/")
            
            let elapsedSeconds = endTime!.timeIntervalSince(startTime!)
            let min = Int(elapsedSeconds / 60)
            let units = (min == 1) ? "minute" : "minutes"
            let duration = "\(min) \(units)"
            
            // Write the summary to disk for debugging purposes
            let file = "game-records.txt"
            let directory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .allDomainsMask, true).first!
            let path = URL(fileURLWithPath: directory).appendingPathComponent(file)
            
            let summary = "\n\n----------\n\(winningTeam) def. \(losingTeam) | \(scoreSummary) | \(duration) | \(Date().description)\n"
            let summaryData = summary.data(using: String.Encoding.utf8, allowLossyConversion: false)!
            
            var apiData: Data?
            if JSONSerialization.isValidJSONObject(jsonData()) {
                apiData = try? JSONSerialization.data(withJSONObject: jsonData(), options: JSONSerialization.WritingOptions.prettyPrinted)
            } else {
                print("WARNING: API data summary is not a valid JSON object")
            }
            
            if FileManager.default.fileExists(atPath: path.path) {
                if let fileHandle = FileHandle(forWritingAtPath: path.path) {
                    fileHandle.seekToEndOfFile()
                    fileHandle.write(summaryData)
                    
                    if let apiData = apiData {
                        fileHandle.write(apiData)
                        
                        if type == .singles {
                            API.shared.createSinglesMatch(with: apiData)
                        }
                    } else {
                        print("WARNING: Failed writing API data to the log :[")
                    }
                    
                    fileHandle.closeFile()
                }
            } else {
                try! summaryData.write(to: path, options: .atomic)
            }
            
            // Then send it to slack
            // We might have a timing issue here with too much being sent at the end (score update, game update, match over?)
            // Delay this a bit to make sure it gets sent last
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: {
                self.sendToSlack("\(winningTeam) def. \(losingTeam)", summary: self.scoreSummary, footer: "Match duration: \(duration)")
            })
            
            return true
        } else {
            return false
        }
    }
    
    func jsonData() -> [String:Any] {
        let iso = ISO8601DateFormatter()
        
        let gamesJSON = games.map { $0.jsonData() }
        
        return [
            "winner": redWins > blueWins ? redTeam.first!.id : blueTeam.first!.id,
            "loser": redWins > blueWins ? blueTeam.first!.id : redTeam.first!.id,
            "firstServer": initialFirstServe == .red ? redTeam.first!.id : blueTeam.first!.id,
            "startTime": iso.string(from: startTime!),
            "endTime": iso.string(from: endTime!),
            "games": gamesJSON
        ]
    }
    
    // MARK: - Slack Methods
    func postMatchStartToSlack() {
        guard Config.slackToken != "<SLACK_TOKEN>" else { return }
        
//        let announcements = [
//            "Grab your popcorn, a match is starting!",
//            "Yo dawg, I heard you like to watch ping-pong",
//            "A tiny tennis match is underway",
//            "To the small green court!"
//        ]
//        let randomIndex = Int(arc4random_uniform(UInt32(announcements.count)))
//        let randomMessage = announcements[randomIndex]
        
        let redPlayers = redTeam.map{$0.name}.joined(separator: "/")
        let bluePlayers = blueTeam.map{$0.name}.joined(separator: "/")
        
        let message = "username=Score Bot&icon_emoji=:pingpong:&channel=\(Config.slackChannel)&attachments=[{ 'title': '\(redPlayers) vs. \(bluePlayers)', 'footer': 'Warming up', 'fallback': '\(redPlayers) vs \(bluePlayers)' }]&token=\(Config.slackToken)"
        let messageData = message.data(using: String.Encoding.utf8)
        
        let url = URL(string: "https://slack.com/api/chat.postMessage")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = messageData
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            let json = try! JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:AnyObject]
            let channel = json["channel"] as! String
            
            // FIXME: I think this can be grabbed at the top level as well
            let message = json["message"] as! [String:AnyObject]
            let ts = message["ts"] as! String
            
            slack_ts = ts
            slack_channelID = channel
        }
        task.resume()
    }
    
    func updateGameScoreToSlack() {
        guard Config.slackToken != "<SLACK_TOKEN>" else { return }
        
        let redPlayers = redTeam.map{$0.name}.joined(separator: "/")
        let bluePlayers = blueTeam.map{$0.name}.joined(separator: "/")
        
        // Match summary (by games won)
        var matchSummary = ""
        if gameCount > 1 && endTime == nil {
            if redWins == blueWins {
                matchSummary = "_Tied: \(redWins) - \(blueWins)_\n"
            } else if redWins > blueWins {
                matchSummary = "_\(redPlayers) leads: \(redWins) - \(blueWins)_\n"
            } else {
                matchSummary = "_\(bluePlayers) leads: \(blueWins) - \(redWins)_\n"
            }
        }
        
        // Detailed score summary
        var scores = [String]()
        for game in games {
            scores.append("\(game.redScore)-\(game.blueScore)")
        }
        let scoreSummary = scores.joined(separator: ", ")
        
        let message = "username=Score Bot&icon_emoji=:pingpong:&channel=\(slack_channelID)&attachments=[{ 'title': '\(redPlayers) vs. \(bluePlayers)', 'text': '\(matchSummary)\(scoreSummary)', 'footer': 'In progress', 'mrkdwn_in': ['text'] }]&token=\(Config.slackToken)&ts=\(slack_ts)"
        let messageData = message.data(using: String.Encoding.utf8)
        
        let url = URL(string: "https://slack.com/api/chat.update")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = messageData
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
//            print(error as Any)
//            print(response as Any)
        }
        task.resume()
    }
    
    func sendToSlack(_ title: String, summary: String, footer: String) {
        guard Config.slackToken != "<SLACK_TOKEN>" else { return }
        
        let message = "username=Score Bot&icon_emoji=:pingpong:&channel=\(slack_channelID)&attachments=[{ 'color': '#219F46', 'title': '\(title)', 'text': '\(summary)', 'footer': '\(footer)', 'mrkdwn_in': ['text'] }]&token=\(Config.slackToken)&ts=\(slack_ts)"
        let messageData = message.data(using: .utf8)
        
        let url = URL(string: "https://slack.com/api/chat.update")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = messageData
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
//            print("\(response): \(error)")
        })
        
        task.resume()
    }
}
