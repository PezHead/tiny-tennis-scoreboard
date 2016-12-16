//
//  PlayersViewController.swift
//  MatchViewer
//
//  Created by David Bireta on 12/15/16.
//  Copyright © 2016 David Bireta. All rights reserved.
//

import UIKit
import TableTennisAPI

struct Player {
    let name: String
    let wins: Int
    let losses: Int
}

class PlayersViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var playerMapping = [String:String]()
    var playersArray = [Player]()
    var matches = [Match]()

    override func viewDidLoad() {
        super.viewDidLoad()

        API.shared.getPlayers { (players) in
            for player in players {
                self.playerMapping[player.id] = player.name
            }
            
            
            // Nested API calls :/
            API.shared.getMatches { (matches) in
                let sortedMatches = matches.sorted(by: { (first, second) -> Bool in
                    first.date < second.date
                })
                
                for match in sortedMatches {
                    let winner = self.playerMapping[match.winner]!
                    let loser = self.playerMapping[match.loser]!
                    
                    let dateFormatter = ISO8601DateFormatter()
                    let date = dateFormatter.date(from: match.date)!
                    
                    let shortFormatter = DateFormatter()
                    shortFormatter.dateStyle = .medium
                    
                    print("\(shortFormatter.string(from: date)): \(winner) def. \(loser)")
                    self.matches.append(match)
                }
                
                // Player calc
                for player in players {
                    let id = player.id
                    let wins = matches.filter( { (match) -> Bool in
                        match.winner == id
                    }).count
                    let losses = matches.filter( { (match) -> Bool in
                        match.loser == id
                    }).count
                    
                    let p = Player(name: player.name, wins: wins, losses: losses)
                    self.playersArray.append(p)
                }
                
                self.playersArray.sort(by: { (first, second) -> Bool in
                    if first.wins == 0 && first.losses == 0 {
                        return false
                    }
                    
                    if second.wins == 0 && second.losses == 0 {
                        return true
                    }
                    
                    let f = Double(first.wins) / Double(first.wins + first.losses)
                    let s = Double(second.wins) / Double(second.wins + second.losses)
                    return f > s
                })
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
}

extension PlayersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playersArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlayerCell", for: indexPath)
        let player = playersArray[indexPath.row]
        
        cell.textLabel?.text = player.name
        let winPct = Double(player.wins) / Double(player.wins + player.losses) * 100.0
        cell.detailTextLabel?.text = "\(player.wins) wins, \(player.losses) losses    Win %: \(String.init(format: "%.2f", winPct))"
        
        return cell
    }
}
