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
    let nickname: String
    let phoeneticName: String
    let avatar: String
    let id: String // Network based ID
    
    var avatarImage: UIImage {
        guard id != "" else {
            return UIImage(named: "default")!
        }
        
        return ImageStore.shared.avatar(for: self)
    }
    
    var lastName: String? {
        return name.components(separatedBy: " ").last
    }
    
    // TODO: This can probably go away when we remove 'ChampionsTome'
    init(name: String, avatar: String, phoeneticName: String = "") {
        self.name = name
        self.nickname = "NICK"
        self.avatar = avatar
        self.phoeneticName = phoeneticName
        self.id = ""
    }
    
    init?(jsonData: [String: Any]) {
        guard let name = jsonData["fullName"] as? String,
            let nickname = jsonData["nickname"] as? String,
            let phoneticName = jsonData["phoneticNickname"] as? String,
            let avatarURL = jsonData["avatarUrl"] as? String,
            let id = jsonData["id"] as? String
            else {
                return nil
        }
        
        self.name = name
        self.nickname = nickname
        if phoneticName.characters.count == 0  {
            if let lastName = name.components(separatedBy: " ").last {
                self.phoeneticName = lastName
            } else {
                self.phoeneticName = name
            }
        } else {
            self.phoeneticName = phoneticName
        }
        self.avatar = avatarURL
        self.id = id
    }
    
    func dictionaryRep() -> [String: Any] {
        return [
            "fullName": name,
            "nickname": nickname,
            "phoneticNickname": phoeneticName,
            "avatarUrl": avatar,
            "id": id
        ]
    }
}

func ==(lhs: Champion, rhs: Champion) -> Bool {
    return lhs.id == rhs.id
}
