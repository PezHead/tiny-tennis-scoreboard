//
//  Point.swift
//  Tiny Tennis
//
//  Created by David Bireta on 10/15/16.
//  Copyright © 2016 David Bireta. All rights reserved.
//

struct Point {
    let server: Champion
    let receiver: Champion
    let winner: Champion
    let order: Int
    
    func jsonData() -> [String:Any] {
        return [
            "server": server.id,
            "receiver": receiver.id,
            "winner": winner.id
        ]
    }
}
