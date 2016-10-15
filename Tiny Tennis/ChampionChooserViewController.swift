//
//  ChampionChooserViewController.swift
//  Tiny Tennis
//
//  Created by David Bireta on 10/15/16.
//  Copyright © 2016 David Bireta. All rights reserved.
//

import UIKit

protocol ChooserDelegate {
    func didSelectChampion(_ champion: Champion)
}

class ChampionChooserViewController: UICollectionViewController {
    var delegate: ChooserDelegate?
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ChampionsTome().members.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChampionCell", for: indexPath) as! ChampionCell
        let champion = ChampionsTome().members[(indexPath as NSIndexPath).row]
        
        cell.nameLabel.text = champion.name
        cell.imageView.image = UIImage(named: champion.avatar)
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let champion = ChampionsTome().members[(indexPath as NSIndexPath).row]
        
        delegate?.didSelectChampion(champion)
    }
    
}
