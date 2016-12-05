//
//  ViewController.swift
//  Tiny Tennis
//
//  Created by David Bireta on 10/15/16.
//  Copyright © 2016 David Bireta. All rights reserved.
//

import UIKit
import QuartzCore

class ViewController: UIViewController {
    
    // MARK:- IBOutlets
    @IBOutlet var championCollectionView: UICollectionView!
    @IBOutlet var leftPlayerImageView: UIImageView!
    @IBOutlet var leftPartnerImageView: UIImageView!
    @IBOutlet var rightPlayerImageView: UIImageView!
    @IBOutlet var rightPartnerImageView: UIImageView!
    @IBOutlet var leftTeamStackView: UIStackView!
    @IBOutlet var rightTeamStackView: UIStackView!
    @IBOutlet var startButton: UIButton!
    
    
    // MARK:- Properties
    
    // Private properties
    fileprivate var championList = [Champion]()
    fileprivate var removedView: UIImageView?
    fileprivate var input: FlicInput?
    fileprivate var fruitInput: FruitButton?
    
    // If array conatains 1 or 2 then first is Left Team, second is Right Team
    // If array contains 3 or 4 then first two are Left Team, second two (or just third) is Right Team
    fileprivate var champions = [Champion]() {
        didSet {
            // Show/Hide start button
            if champions.count == 2 || champions.count == 4 {
                startButton.transform = startButton.transform.scaledBy(x: 0.1, y: 0.1)
                startButton.alpha = 0
                startButton.isHidden = false
                
                UIView.animate(withDuration: 0.4, delay: 0.0, options: UIViewAnimationOptions(), animations: {
                    self.startButton.transform = CGAffineTransform.identity
                    self.startButton.alpha = 1
                    }, completion: { finished in
                        // Completion
                })
            } else {
                UIView.animate(withDuration: 0.4, delay: 0, options: UIViewAnimationOptions(), animations: {
                    self.startButton.alpha = 0
                    }, completion: { finished in
                        self.startButton.isHidden = true
                })
            }
            
            
            // Show/Hide partner avatars based on number of players
            if champions.count > 2 {
                leftPartnerImageView.isHidden = false
                rightPartnerImageView.isHidden = false
            } else {
                leftPartnerImageView.isHidden = true
                rightPartnerImageView.isHidden = true
            }
            
            
            // Setting selected champion avatars
            for imageView in [leftPlayerImageView, leftPartnerImageView, rightPlayerImageView, rightPartnerImageView] {
                setAvatar(nil, forView: imageView!, animted: false)
            }
            
            if champions.count == 1 {
                if oldValue.count == 0 || removedView == rightPlayerImageView {
                    setAvatar(champions[0].avatarImage, forView: leftPlayerImageView)
                } else {
                    animateAvatarImage(champions[0].avatarImage, fromView: rightPlayerImageView, toView: leftPlayerImageView)
                }
            } else if champions.count == 2 {
                if oldValue.count == 3 {
                    if removedView == rightPlayerImageView {
                        animateAvatarImage(champions[1].avatarImage, fromView: leftPartnerImageView, toView: rightPlayerImageView)
                        animateAvatarImage(champions[0].avatarImage, fromView: leftPlayerImageView, toView: leftPlayerImageView)
                    } else if removedView == leftPartnerImageView {
                        animateAvatarImage(champions[1].avatarImage, fromView: rightPlayerImageView, toView: rightPlayerImageView)
                        animateAvatarImage(champions[0].avatarImage, fromView: leftPlayerImageView, toView: leftPlayerImageView)
                    } else if removedView == leftPlayerImageView {
                        animateAvatarImage(champions[1].avatarImage, fromView: rightPlayerImageView, toView: rightPlayerImageView)
                        animateAvatarImage(champions[0].avatarImage, fromView: leftPartnerImageView, toView: leftPlayerImageView)
                    }
                } else {
                    setAvatar(champions[0].avatarImage, forView: leftPlayerImageView)
                    setAvatar(champions[1].avatarImage, forView: rightPlayerImageView)
                }
            } else if champions.count == 3 {
                if oldValue.count == 2 {
                    // Slide over the player with nifty animation
                    animateAvatarImage(champions[1].avatarImage, fromView: rightPlayerImageView, toView: leftPartnerImageView)
                    animateAvatarImage(champions[0].avatarImage, fromView: leftPlayerImageView, toView: leftPlayerImageView)
                    setAvatar(champions[2].avatarImage, forView: rightPlayerImageView)
                } else {
                    leftPlayerImageView.image = self.champions[0].avatarImage
                    leftPartnerImageView.image = self.champions[1].avatarImage
                    rightPlayerImageView.image = champions[2].avatarImage
                }
                
            } else if champions.count == 4 {
                leftPlayerImageView.image = champions[0].avatarImage
                leftPartnerImageView.image = champions[1].avatarImage
                rightPlayerImageView.image = champions[2].avatarImage
                setAvatar(champions[3].avatarImage, forView: rightPartnerImageView)
            }
        }
    }
    
    fileprivate func animateAvatarImage(_ image: UIImage, fromView: UIImageView, toView: UIImageView) {
        let fromStack = fromView == leftPlayerImageView || fromView == leftPartnerImageView ? leftTeamStackView : rightTeamStackView
        let toStack = toView == leftPlayerImageView || toView == leftPartnerImageView ? leftTeamStackView : rightTeamStackView
        
        let animatedAvatar = UIImageView(image: image)
        animatedAvatar.layer.cornerRadius = 8
        animatedAvatar.clipsToBounds = true
        animatedAvatar.contentMode = .scaleAspectFill
        animatedAvatar.frame = (fromStack?.convert(fromView.frame, to: view))!
        view.addSubview(animatedAvatar)
        
        UIView.animate(withDuration: 0.9, delay: 0.0, options: UIViewAnimationOptions(), animations: {
            //                    animatedAvatar.frame = self.leftTeamStackView.convertRect(self.leftPartnerImageView.frame, toView: self.view)
            // HACK HACK: Need to figure out how to get frame *AFTER* the stack view has re-layedout views
            let r = CGRect(x: 152.5, y: 0, width: 147.5, height: 300)
            //            let r2 = CGRect(x: 0, y: 0, width: 147.5, height: 300)
            let r3 = CGRect(x: 0, y: 0, width: 300, height: 300)
            
            var rect: CGRect
            if toView == self.leftPartnerImageView {
                rect = r
            } else {
                rect = r3
            }
            
            animatedAvatar.frame = (toStack?.convert(rect, to: self.view))!
            }, completion: { finished in
                animatedAvatar.removeFromSuperview()
                
                self.setAvatar(image, forView: toView, animted: false)
        })
    }
    
    fileprivate func setAvatar(_ avatar: UIImage?, forView view: UIImageView, animted: Bool = true) {
        guard view.image != avatar else { return }
        
        if !animted {
            view.image = avatar
            return
        }
        
        UIView.transition(with: view, duration: 0.3, options: .transitionCrossDissolve, animations: {
            view.image = avatar
        }) { finished in
            //
        }
    }
    
    
    // MARK: - View Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        leftPartnerImageView.isHidden = true
        rightPartnerImageView.isHidden = true
        startButton.isHidden = true
        
        for imageView in [leftPlayerImageView, leftPartnerImageView, rightPlayerImageView, rightPartnerImageView] {
            let tapper = UITapGestureRecognizer(target: self, action: #selector(handleTap))
            imageView?.addGestureRecognizer(tapper)
            
            imageView?.layer.borderWidth = 0.5
            imageView?.layer.borderColor = UIColor.black.withAlphaComponent(0.3).cgColor
        }
        
        input = FlicInput()
        if !input!.initialize() {
            print("Error initializing flic input")
        }
        
        fruitInput = FruitButton()
        if !fruitInput!.initialize() {
            print("Error initializing fruit buttons")
        }
        
        ChampionStore.all { champs in
            DispatchQueue.main.async {
                self.championList = champs
                self.championCollectionView.reloadData()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        champions.removeAll()
        championCollectionView.reloadData()
    }
    
    
    func handleTap(_ gesture: UITapGestureRecognizer) {
        if gesture.view == leftPlayerImageView {
            removedView = leftPlayerImageView
            
            champions.removeFirst()
        } else if gesture.view == leftPartnerImageView {
            removedView = leftPartnerImageView
            
            champions.remove(at: 1)
        } else if gesture.view == rightPlayerImageView {
            removedView = rightPlayerImageView
            
            if champions.count == 2 {
                champions.removeLast()
            } else if champions.count == 3 {
                champions.removeLast()
            } else if champions.count == 4 {
                champions.remove(at: 2)
            }
        } else if gesture.view == rightPartnerImageView {
            removedView = rightPartnerImageView
            
            champions.removeLast()
        }
        
        championCollectionView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "startMatch" {
            let destVC = segue.destination as! ScoreboardViewController
            destVC.leftChampion = champions[0]
            destVC.rightChampion = champions[1]
            
            if champions.count == 4 {
                destVC.leftPartner = champions[1]
                destVC.rightChampion = champions[2]
                destVC.rightPartner = champions[3]
            }
            
            input?.delegate = destVC
            fruitInput?.delegate = destVC
        }
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return championList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChampionCell", for: indexPath) as! ChampionCell
        
        let champion = championList[(indexPath as NSIndexPath).row]
        
        cell.imageView.image = champion.avatarImage
        cell.nameLabel.text = champion.nickname
        
        if champions.contains(champion) {
            // Dim champion so they won't be selected twice
            cell.alpha = 0.3
        } else if champions.count == 4 {
            // More darkly dim the rest of the champions if we have maxed out at 4 playrs
            cell.alpha = 0.075
        } else {
            cell.alpha = 1.0
        }
        
        return cell
    }
}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //        // CRAZY ANIMATIONS!! :]
        //        guard let cell = collectionView.cellForItemAtIndexPath(indexPath) else { return }
        //        let snapshot = cell.snapshotViewAfterScreenUpdates(true)
        //        snapshot.frame = collectionView.convertRect(cell.frame, toView: view)
        //        view.addSubview(snapshot)
        //
        //        UIView.animateWithDuration(0.6, animations: {
        //            snapshot.frame = self.leftPlayerImageView.convertRect(self.leftPlayerImageView.frame, toView: self.view)
        //        }) { finished in
        //            snapshot.removeFromSuperview()
        //        }
        //
        guard champions.count < 4 else { return }
        
        let champion = championList[(indexPath as NSIndexPath).row]
        guard !champions.contains(champion) else {
            print("This champion was already selected")
            return
        }
        
        champions.append(champion)
        
        if champions.count == 4 {
            // Reload all the cells so that everyone is disabled
            championCollectionView.reloadItems(at: championCollectionView.indexPathsForVisibleItems)
        } else {
            // Otherwise, be smart about only reloading selected item
            collectionView.reloadItems(at: [indexPath])
        }
    }
}

