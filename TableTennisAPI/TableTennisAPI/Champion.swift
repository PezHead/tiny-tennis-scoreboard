//
//  Champion.swift
//  Tiny Tennis
//
//  Created by David Bireta on 10/15/16.
//  Copyright © 2016 David Bireta. All rights reserved.
//

import UIKit

public struct Champion: Equatable {
    public let name: String
    public let nickname: String
    public let phoeneticName: String
    public let avatar: String
    public let id: String // Network based ID
    
    public var avatarImage: UIImage {
        guard id != "" else {
            return UIImage(named: "default")!
        }
        
        return ImageStore.shared.avatar(for: self)
    }
    
    public var lastName: String? {
        return name.components(separatedBy: " ").last
    }
    
    public init?(jsonData: [String: Any]) {
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
    
    public func dictionaryRep() -> [String: Any] {
        return [
            "fullName": name,
            "nickname": nickname,
            "phoneticNickname": phoeneticName,
            "avatarUrl": avatar,
            "id": id
        ]
    }
}

public func ==(lhs: Champion, rhs: Champion) -> Bool {
    return lhs.id == rhs.id
}
