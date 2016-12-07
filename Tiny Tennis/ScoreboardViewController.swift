//
//  ScoreboardViewController.swift
//  Tiny Tennis
//
//  Created by David Bireta on 10/15/16.
//  Copyright © 2016 David Bireta. All rights reserved.
//

import UIKit

class ScoreboardViewController: UIViewController {
    // MARK:- Properties
    @IBOutlet var leftView: UIView!
    @IBOutlet var rightView: UIView!
    @IBOutlet var redScoreLabel: UILabel!
    @IBOutlet var blueScoreLabel: UILabel!
    @IBOutlet var matchDurationLabel: UILabel!
    @IBOutlet var leftServiceLabel: UILabel!
    @IBOutlet var leftPartnerServiceLabel: UILabel!
    @IBOutlet var rightServiceLabel: UILabel!
    @IBOutlet var rightPartnerServiceLabel: UILabel!
    
    @IBOutlet var leftAvatar: UIImageView!
    @IBOutlet var leftPartnerAvatar: UIImageView!
    @IBOutlet var leftPartnerStackView: UIStackView!
    @IBOutlet var leftChampionLabel: UILabel!
    @IBOutlet var leftChampionPartnerLabel: UILabel!
    @IBOutlet var rightAvatar: UIImageView!
    @IBOutlet var rightPartnerAvatar: UIImageView!
    @IBOutlet var rightPartnerStackView: UIStackView!
    @IBOutlet var rightChampionLabel: UILabel!
    @IBOutlet var rightChampionpartnerLabel: UILabel!
    @IBOutlet var redGame1: UIImageView!
    @IBOutlet var redGame2: UIImageView!
    @IBOutlet var redGame3: UIImageView!
    @IBOutlet var blueGame1: UIImageView!
    @IBOutlet var blueGame2: UIImageView!
    @IBOutlet var blueGame3: UIImageView!
    
    var minuteTimer = Timer()
    var gameCount = 1
    
    // TODO: Hmm...
    var leftChampion: Champion! {
        didSet {
            print("left champ")
        }
    }
    var rightChampion: Champion! {
        didSet {
            print("right champ")
        }
    }
    var leftPartner: Champion? {
        didSet {
            print("what")
        }
    }
    var rightPartner: Champion? {
        didSet {
            print("Www")
        }
    }
    
    // Private properties
    fileprivate var isMuted = false
    fileprivate var chooserLeft = false
    fileprivate var viewModel = MatchViewModel()
    
    
    // MARK:- Public methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: Hmm...
        var lChamps: [Champion] = [leftChampion]
        if let partner = leftPartner {
            lChamps.append(partner)
        }
        viewModel.setChampions(lChamps, forSide: .left)
        
        var rChamps: [Champion] = [rightChampion]
        if let p = rightPartner {
            rChamps.append(p)
        }
        viewModel.setChampions(rChamps, forSide: .right)
        
        viewModel.delegate = self
        
        // Used to update the match duration every minute
        minuteTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(updateUI), userInfo: nil, repeats: true)
        
        let addScoreGesture = UITapGestureRecognizer(target: self, action: #selector(addScore))
        addScoreGesture.numberOfTapsRequired = 1
        view.addGestureRecognizer(addScoreGesture)
        
        let subtractScoreGesture = UISwipeGestureRecognizer(target: self, action: #selector(undoPoint))
        subtractScoreGesture.direction = .down
        view.addGestureRecognizer(subtractScoreGesture)
        
        
        // Set up a secret gesture to toggle the server at the beginning of the game
        let secretGesture = UILongPressGestureRecognizer(target: self, action: #selector(superSecretServerToggle))
        secretGesture.minimumPressDuration = 2.0
        leftAvatar.addGestureRecognizer(secretGesture)
        
        viewModel.startMatch()
    }
    
    @IBAction func handleBack(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func handleMuteToggle(_ sender: UIButton) {
        isMuted = !isMuted
        updateUI()
    }
    
    func updateUI() {
        redScoreLabel.text = viewModel.leftScore
        blueScoreLabel.text = viewModel.rightScore
        
        matchDurationLabel.text = viewModel.durationDesription
        
        leftServiceLabel.text = viewModel.leftServing
        leftPartnerServiceLabel.text = viewModel.leftPartnerServing
        rightServiceLabel.text = viewModel.rightServing
        rightPartnerServiceLabel.text = viewModel.rightPartnerServing
        
        leftView.backgroundColor = viewModel.leftColor
        rightView.backgroundColor = viewModel.rightColor
        
        leftAvatar.image = viewModel.leftAvatar
        leftPartnerAvatar.image = viewModel.leftPartnerAvatar
        leftChampionLabel.text = viewModel.leftChampionName
        leftChampionPartnerLabel.text = viewModel.leftChampionPartnerName
        rightAvatar.image = viewModel.rightAvatar
        rightPartnerAvatar.image = viewModel.rightPartnerAvatar
        rightChampionLabel.text = viewModel.rightChampionName
        rightChampionpartnerLabel.text = viewModel.rightChampionPartnerName
        
        // FIXME: Still some logic in here.
        redGame1.isHidden = viewModel.leftWins == 0
        redGame2.isHidden = viewModel.leftWins <= 1
        redGame3.isHidden = viewModel.leftWins <= 2
        blueGame1.isHidden = viewModel.rightWins == 0
        blueGame2.isHidden = viewModel.rightWins <= 1
        blueGame3.isHidden = viewModel.rightWins <= 2
        
        if (viewModel.isSingles) {
            leftPartnerStackView.isHidden = true
            rightPartnerStackView.isHidden = true
        } else {
            leftPartnerStackView.isHidden = false
            rightPartnerStackView.isHidden = false
        }
        
        // Highlight labels under avatars to try and better show who is serving/receiving
        leftServiceLabel.backgroundColor = leftServiceLabel.text == "." ? UIColor.clear : UIColor.black.withAlphaComponent(0.15)
        leftPartnerServiceLabel.backgroundColor = leftPartnerServiceLabel.text == "." ? UIColor.clear : UIColor.black.withAlphaComponent(0.15)
        rightServiceLabel.backgroundColor = rightServiceLabel.text == "." ? UIColor.clear : UIColor.black.withAlphaComponent(0.15)
        rightPartnerServiceLabel.backgroundColor = rightPartnerServiceLabel.text == "." ? UIColor.clear : UIColor.black.withAlphaComponent(0.15)
    }
    
    func addScore(_ tap: UITapGestureRecognizer) {
        let point = tap.location(in: view)
        
        if point.x < 512 {
            registerPointForSide(.left)
        } else {
            registerPointForSide(.right)
        }
        
    }
    
    fileprivate func registerPointForSide(_ side: Side) {
        // Don't add to the score if the game is already over
        guard viewModel.winningPlayerNames == nil else { return }
        
        viewModel.addPointFor(side)
    }
    
    @objc func undoPoint() {
        viewModel.undoLastPoint()
    }
    
    func showWinner() {
        let victoryVC = storyboard?.instantiateViewController(withIdentifier: "MatchVictoryVC") as! MatchVictoryViewController
        
        victoryVC.match = viewModel.victoryMatch
        
        present(victoryVC, animated: true) {
            let dispatchTime: DispatchTime = DispatchTime.now() + Double(Int64(10.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                self.dismiss(animated: true, completion: {
                    self.handleBack(self)
                })
            }
        }
    }
    
    @objc fileprivate func superSecretServerToggle(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        
        viewModel.toggleInitialServer()
    }
}

extension ScoreboardViewController: MatchViewModelDelegate {
    func didUpdateProperty() {
        // SLEDGEHAMMER!!
        updateUI()
    }
    
    func confirmGameWonBy(_ winningTeam: Team) {
        // FIXME: Move this once the struct/delegate problem is all fixed
        Announcer.shared.announceGameWinner(withMatch: viewModel.victoryMatch)
        
        if viewModel.winningChampions != nil {
            let dispatchTime: DispatchTime = DispatchTime.now() + Double(Int64(1.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                self.showWinner()
                self.viewModel.confirmGameFinished()
            }
        } else {
            let dispatchTime: DispatchTime = DispatchTime.now() + Double(Int64(4.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                self.viewModel.confirmGameFinished()
            }
        }
        
        
    }
}

extension ScoreboardViewController: InputDelegate {
    func addScoreLeft() {
        registerPointForSide(.left)
    }
    
    func addScoreRight() {
        registerPointForSide(.right)
    }
    
    func undoLastPoint() {
        undoPoint()
    }
}
