//
//  GoogleAuth.swift
//  
//
//  Created by 김태완 on 2021/12/21.
//

import Foundation

import GoogleSignIn


public final class GoogleAuth {
    public static let shared = GoogleAuth()
    
    public var isSinged: Bool {
        return false
    }
    
    var user: GIDGoogleUser? {
        didSet {
            GoogleDrive.shared.configuration(with: user)
        }
    }
    
    public func signIn(clientID: String, with scopes: [Scope], presenting: UIViewController, callback: ((_ success: Bool, Error?) -> Void)?) {
        guard isSinged == false else {
            callback?(true, nil)
            return
        }
        let configuration = GIDConfiguration(clientID: clientID)
        
        GIDSignIn
            .sharedInstance
            .signIn(with: configuration, presenting: presenting) { [weak self] user, error in
                guard !scopes.isEmpty else {
                    self?.user = user
                    callback?(user != nil, error)
                    return
                }
                self?.addScopes(scopes, presenting: presenting) { user, error in
                    self?.user = user
                    callback?(user != nil, error)
                }
            }
    }
    
    public func signOut() {
        GIDSignIn.sharedInstance.signOut()
    }
    
    public func restorePreviousSignIn() {
        GIDSignIn
            .sharedInstance
            .restorePreviousSignIn { [weak self] user, error in
                self?.user = user
                if error != nil || user == nil {
                    // Show the app's signed-out state.
                } else {
                    // Show the app's signed-in state.
                }
            }
    }
    
    // AppDelegate GIDSingIn handle
    public func handle(_ url: URL) -> Bool {
        GIDSignIn.sharedInstance.handle(url)
    }
    
    
    func addScopes(_ scopes: [Scope], presenting: UIViewController, callback: ((GIDGoogleUser?, Error?) -> Void)?) {
        let scopesPaths = scopes.map { $0.rawValue}
        GIDSignIn
            .sharedInstance
            .addScopes(scopesPaths,  presenting: presenting) { user, error in
                callback?(user, error)
            }
    }
}

extension GoogleAuth {
    public enum State {
        case signedIn
        case signedOut
    }
}

extension GoogleAuth {
    public struct Scope {
        public var rawValue: String
        
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
    }
}

extension GoogleAuth.Scope {
    public static let documents = GoogleAuth.Scope(rawValue: "https://www.googleapis.com/auth/documents")
    public static let documentsReadonly = GoogleAuth.Scope(rawValue: "https://www.googleapis.com/auth/documents.readonly")
    public static let drive = GoogleAuth.Scope(rawValue: "https://www.googleapis.com/auth/drive")
    public static let driveFile  = GoogleAuth.Scope(rawValue: "https://www.googleapis.com/auth/drive.file")
    public static let driveReadonly  = GoogleAuth.Scope(rawValue: "https://www.googleapis.com/auth/drive.readonly")
}
