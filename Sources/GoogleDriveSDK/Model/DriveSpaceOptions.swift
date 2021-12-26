//
//  DriveSpaceOptions.swift
//  
//
//  Created by 김태완 on 2021/12/27.
//

import Foundation



public struct DriveSpaceOptions: OptionSet {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
}

public extension DriveSpaceOptions {
    static let appDataFolder = DriveSpaceOptions(rawValue: 1 << 0)
    static let drive  = DriveSpaceOptions(rawValue: 1 << 1)
    
    static let all: DriveSpaceOptions = [.drive, .appDataFolder]
}


extension DriveSpaceOptions {
    var parents: [String] {
        var spaces: [String] = []
        if contains(.appDataFolder) {
            spaces += ["appDataFolder"]
        }
        if contains(.drive) {
            spaces += ["drive"]
        }
        return spaces
    }
    
    var querySpaces: String? {
        let spaces = parents
        guard !spaces.isEmpty else { return nil }
        return spaces.joined(separator: ",")
    }
}
