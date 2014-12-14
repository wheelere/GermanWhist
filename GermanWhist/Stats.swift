//
//  Stats.swift
//  GermanWhist
//
//  Created by Earnest Wheeler on 12/14/14.
//  Copyright (c) 2014 GoldWheels. All rights reserved.
//

import Foundation

class Stats {
    var totalGames: Int
    var gamesWon: Int
    var mostTricksWon: Int
    
    func toPropertyListObject() -> NSDictionary {
        var dictionary: NSMutableDictionary = [
            "totalGames" : totalGames,
            "gamesWon" : gamesWon,
            "mostTricksWon": mostTricksWon]
        return dictionary
    }
    
    init(total: Int, _ games: Int, _ tricks: Int) {
        totalGames = total
        gamesWon = games
        mostTricksWon = tricks
        
    }
    
    convenience init(dictionary: NSDictionary) {
        var total = dictionary["totalGames"] as? Int
        var games = dictionary["gamesWon"] as? Int
        var tricks = dictionary["mostTricksWon"] as? Int
        self.init(total: total!, games!, tricks!)
    }
    
    
}
