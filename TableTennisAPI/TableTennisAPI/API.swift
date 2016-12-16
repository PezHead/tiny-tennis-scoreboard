//
//  API.swift
//  Tiny Tennis
//
//  Created by David Bireta on 10/15/16.
//  Copyright © 2016 David Bireta. All rights reserved.
//

import UIKit


/// Manages all interactions with the table-tennis API.
public class API {
    public static let shared = API()
    
    fileprivate let config = URLSessionConfiguration.default
    fileprivate let session: URLSession
    fileprivate let baseURL = URL(string: "https://mf-table-tennis-api.herokuapp.com/v1")!
    
    fileprivate init() {
        config.httpAdditionalHeaders = ["Authorization": "Bearer \(Config.apiKey)"]
        session = URLSession(configuration: config)
    }
    
    /// Retrieves all player objects.
    ///
    /// - parameter completion: Clousre to be run on a successful response being handled.
    public func getPlayers(_ completion: @escaping ([Champion]) -> Void) {
        let url = baseURL.appendingPathComponent("players")
        let request = URLRequest(url: url)
        
        let task = session.dataTask(with: request) { (data, response, error) in
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
    
    public func createSinglesMatch(with jsonData: Data) {
        let url = baseURL.appendingPathComponent("singles")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = session.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                print(error as Any)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Error getting HTTP response")
                return
            }
            
            guard httpResponse.statusCode == 201 else {
                print("Returned code other than 200: \(httpResponse)")
                return
            }
            
            if let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) {
                if let jsonData = json as? [String:Any] {
                    print("Successfully created singles match with id: \(jsonData["id"])")
                }
            }
        }
        
        task.resume()
    }
    
    public func getMatches(_ completion: @escaping ([Match]) -> Void) {
        let url = baseURL.appendingPathComponent("singles")
        let request = URLRequest(url: url)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                print(error as Any)
                return
            }
            
            if let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) {
                if let jsonData = json as? [Any] {
                    
                    var matches = [Match]()
                    
                    for matchData in jsonData {
                        if let match = Match(jsonData: matchData as! [String:Any]) {
                            matches.append(match)
                        }
                    }
                    
                    completion(matches)
                }
                
//                for case let playerObj as [String: Any] in peeps {
//                    if let champ = Champion(jsonData: playerObj) {
//                        championList.append(champ)
//                    }
//                }
            }
        }
        task.resume()
    }
}
