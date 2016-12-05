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
        var request = URLRequest(url: url)
        request.addValue("Bearer \(Config.apiKey)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                print(error as Any)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Error getting HTTP response")
                return
            }
            
            guard httpResponse.statusCode == 200 else {
                print("Returned code other than 200: \(httpResponse)")
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
    
    static func createSinglesMatch(with jsonData: Data) {
        let url = URL(string: "https://mf-table-tennis-api.herokuapp.com/v1/singles")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(Config.apiKey)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                print(error as Any)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Error getting HTTP response")
                return
            }
            
            guard httpResponse.statusCode == 200 else {
                print("Returned code other than 200: \(httpResponse)")
                return
            }
            
            if let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) {
                if let results = json as? [Any], let result = results.first as? [String:Any] {
                    print("Successfully created singles match with id: \(result["id"])")
                }
            }
        }
        
        task.resume()
    }
}
