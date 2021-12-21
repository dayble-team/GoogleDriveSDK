//
//  MimeType.swift
//  
//
//  Created by 김태완 on 2021/12/21.
//

import Foundation



public struct MimeType: Equatable {
    public var rawValue: String
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

extension MimeType {
    /// https://developers.google.com/drive/api/v3/mime-types
    public static let audio = MimeType(rawValue: "application/vnd.google-apps.audio")
    public static let googleDocs = MimeType(rawValue: "application/vnd.google-apps.document")
    public static let thirdPartyShortcut = MimeType(rawValue: "application/vnd.google-apps.drive-sdk")
    public static let googleDrawing = MimeType(rawValue: "application/vnd.google-apps.drawing")
    public static let googleDriveFile = MimeType(rawValue: "application/vnd.google-apps.file")
    public static let googleDriveFolder = MimeType(rawValue: "application/vnd.google-apps.folder")
    public static let googleForms = MimeType(rawValue: "application/vnd.google-apps.form")
    public static let googleFusionTables = MimeType(rawValue: "application/vnd.google-apps.fusiontable")
    public static let googleMyMaps = MimeType(rawValue: "application/vnd.google-apps.map")
    public static let photo = MimeType(rawValue: "application/vnd.google-apps.photo")
    public static let googleSlides = MimeType(rawValue: "application/vnd.google-apps.presentation")
    public static let googleAppsScripts = MimeType(rawValue: "application/vnd.google-apps.script")
    public static let Shortcut = MimeType(rawValue: "application/vnd.google-apps.shortcut")
    public static let googleSites = MimeType(rawValue: "application/vnd.google-apps.site")
    public static let googleSheets = MimeType(rawValue: "application/vnd.google-apps.spreadsheet")
    public static let unknown = MimeType(rawValue: "application/vnd.google-apps.unknown")
    public static let video = MimeType(rawValue: "application/vnd.google-apps.video")
}


/// https://developer.mozilla.org/ko/docs/Web/HTTP/Basics_of_HTTP/MIME_types
extension MimeType {
    public static let json = MimeType(rawValue: "application/json")
    public static let plain = MimeType(rawValue: "text/plain")
    public static let jpeg = MimeType(rawValue: "image/jpeg")
    public static let png = MimeType(rawValue: "image/png")
}
