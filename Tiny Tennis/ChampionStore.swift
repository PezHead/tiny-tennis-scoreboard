//
//  ChampionStore.swift
//  Tiny Tennis
//
//  Created by David Bireta on 10/20/16.
//  Copyright © 2016 David Bireta. All rights reserved.
//


/// Provides access to available `Champion`s.
class ChampionStore {
    
    /// Returns all of the `Champion`s. 
    /// This will make a API call to fetch champion data. Results will be cached for offline usage.
    ///
    /// - parameter completion: Closure to be called when the final list of champions is compiled.
    static func all(_ completion: @escaping ([Champion]) -> Void) {
        var championList = [Champion]()
        
//        // First load players from the json stored in App Bundle
//        if let fileURL = Bundle.main.url(forResource: "Champions", withExtension: "json") {
        
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let path = dir.appendingPathComponent("combinedPlayers.json")
            let jsonData = try? Data(contentsOf: path)
            let json = try? JSONSerialization.jsonObject(with: jsonData!, options: [])
            
            if let peeps = json as? [Any] {
                for case let playerObj as [String: Any] in peeps {
                    if let champ = Champion(jsonData: playerObj) {
                        championList.append(champ)
                    }
                }
                
                // FIXME: Not a huge fan of calling the completion twice (once for cache, once for network).
                completion(championList)
            }
        }
        
        // Request players from API
        API.getPlayers { champions in
            champions.forEach { champ in
                // Merge updated players with exisitng players
                // Simple approach: Just add players that don't already exist
                if championList.contains(champ) {
                    let index = championList.index(of: champ)!
                    championList.remove(at: index)
                }
                
                championList.append(champ)
            }
            
            // Send completion result
            completion(championList)
            
            // Write updated player list to disk
            do {
                let jsonFriendlyChamps = championList.map({ (champion) -> [String: Any] in
                    return champion.dictionaryRep()
                })
                if JSONSerialization.isValidJSONObject(jsonFriendlyChamps) {
                    let jsonified = try JSONSerialization.data(withJSONObject: jsonFriendlyChamps, options: .prettyPrinted)
                    if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                        let path = dir.appendingPathComponent("combinedPlayers.json")
                        
                        do {
                            try jsonified.write(to: path, options: .atomic)
                        } catch let error {
                            print("Error writing player file: \(error)")
                        }
                    }
                }
            } catch let error {
                print("Error serializing to json: \(error)")
            }
        }
    }
}
