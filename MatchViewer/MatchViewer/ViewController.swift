//
//  ViewController.swift
//  MatchViewer
//
//  Created by David Bireta on 12/13/16.
//  Copyright © 2016 David Bireta. All rights reserved.
//

import UIKit
import TableTennisAPI

class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var playerMapping = [String:String]()
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
                let bireta = "d8842ac0-699a-4901-b3c5-41918075d432"
                let wins = matches.filter( { (match) -> Bool in
                    match.winner == bireta
                }).count
                let losses = matches.filter( { (match) -> Bool in
                    match.loser == bireta
                }).count
                
                print("\(wins+losses) matches: \(wins) wins, \(losses) losses")
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matches.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MatchSummaryCell", for: indexPath) as! MatchSumaryCell
        
        let m = matches[indexPath.row]
        cell.winnerLabel.text = self.playerMapping[m.winner]
        cell.loserLabel.text = self.playerMapping[m.loser]
        
        let dateFormatter = ISO8601DateFormatter()
        let date = dateFormatter.date(from: m.date)!
        
        let shortFormatter = DateFormatter()
        shortFormatter.dateStyle = .medium
        cell.dateLabel.text = shortFormatter.string(from: date)
        
        cell.gameSummaryLabel.text = m.gameSummary()
        
        return cell
    }
}

