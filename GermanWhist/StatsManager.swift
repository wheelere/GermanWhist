//
//  StatsManager.swift
//  GermanWhist
//
//  Created by Earnest Wheeler on 12/14/14.
//  Copyright (c) 2014 GoldWheels. All rights reserved.
//

import Foundation

private let statsManagerInstance = StatsManager()

class StatsManager {
    
    var stats: Stats = Stats(total: 0, 0, 0)
    
    class var sharedStatsManager: StatsManager {
        return statsManagerInstance
    }
    
    init() {
        loadStats()
    }
    
    func saveStats() {
        let docPath = documentsDirectoryPath()
        let statsFilePath = docPath.stringByAppendingPathComponent("stats.plist")
        let statsPropertyObject = stats.toPropertyListObject() as NSDictionary
        
        let data = NSPropertyListSerialization.dataWithPropertyList(statsPropertyObject, format: .XMLFormat_v1_0, options: 0, error: nil)
        data?.writeToFile(statsFilePath, atomically: true)
    }
    
    func loadStats() {
        let statsFilePath = documentsDirectoryPath().stringByAppendingPathComponent("stats.plist")
        let plistData: NSData? = NSData(contentsOfFile: statsFilePath)
        if plistData != nil {
            let statsPropertyObject = NSPropertyListSerialization.propertyListWithData(plistData!, options: 0, format: nil, error: nil) as NSDictionary
            stats = Stats(dictionary: statsPropertyObject)
            }
        else {
            stats = Stats(total: 0,0,0)
        }
    }
    
    func documentsDirectoryPath() -> String {
        var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as [String]
        
        return paths.first!
    }
    
}