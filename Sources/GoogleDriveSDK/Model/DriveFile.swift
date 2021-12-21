//
//  DriveFile.swift
//  
//
//  Created by 김태완 on 2021/12/21.
//

import Foundation


public struct DriveFile {
    public let id: String
    public let name: String
    public let originalFilename: String
    
    public let mimeType: MimeType
    
    public let hasThumbnail: Bool
    
    public let size: UInt64
    /// GMT
    public let createdAt: Date
    /// GMT
    public let modifiedAt: Date
}

