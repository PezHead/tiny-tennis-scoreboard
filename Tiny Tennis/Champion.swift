//
//  Champion.swift
//  Tiny Tennis
//
//  Created by David Bireta on 10/15/16.
//  Copyright © 2016 David Bireta. All rights reserved.
//

import UIKit

struct Champion: Equatable {
    let name: String
    var phoeneticName: String
    let avatar: String
    
    var avatarImage: UIImage {
        if let image = UIImage(named: avatar) {
            return image
        } else {
            return UIImage(named: "default")!
        }
    }
    
    init(name: String, avatar: String, phoeneticName: String = "") {
        self.name = name
        self.avatar = avatar
        self.phoeneticName = phoeneticName
        if phoeneticName.characters.count == 0 {
            self.phoeneticName = name
        } else {
            self.phoeneticName = phoeneticName
        }
    }
}

func ==(lhs: Champion, rhs: Champion) -> Bool {
    return lhs.name == rhs.name
}
