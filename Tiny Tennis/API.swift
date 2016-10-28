//
//  API.swift
//  Tiny Tennis
//
//  Created by David Bireta on 10/15/16.
//  Copyright © 2016 David Bireta. All rights reserved.
//

import UIKit


/// Manages all interactions with the table-tennis API.
class API {
    
    /// Retrieves all player objects.
    ///
    /// - parameter completion: Clousre to be run on a successful response being handled.
    static func getPlayers(_ completion: @escaping ([Champion]) -> Void) {
        let url = URL(string: "https://mf-table-tennis-api.herokuapp.com/v1/players")!
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard error == nil else {
                print(error as Any)
                return
            }
            
            if let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) {
                if let results = json as? [Any] {
                    
                    var champs = [Champion]()
                    
                    for case let p as [String: Any] in results {
                        if let champ = Champion(jsonData: p) {
                            champs.append(champ)
                        }
                    }
                    
                    completion(champs)
                }
            }
        }
        
        task.resume()
    }
}
