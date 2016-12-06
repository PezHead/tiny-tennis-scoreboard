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
    static let shared = API()
    
    private let config = URLSessionConfiguration.default
    private let session: URLSession
    private let baseURL = URL(string: "https://mf-table-tennis-api.herokuapp.com/v1")!
    
    private init() {
        config.httpAdditionalHeaders = ["Authorization": "Bearer \(Config.apiKey)"]
        session = URLSession(configuration: config)
    }
    
    /// Retrieves all player objects.
    ///
    /// - parameter completion: Clousre to be run on a successful response being handled.
    func getPlayers(_ completion: @escaping ([Champion]) -> Void) {
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
    
    func createSinglesMatch(with jsonData: Data) {
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
}
