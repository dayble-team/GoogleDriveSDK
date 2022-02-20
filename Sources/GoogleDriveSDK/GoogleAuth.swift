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
    
    public var isSignedIn: Bool {
        GIDSignIn.sharedInstance.hasPreviousSignIn()
    }
    
    var configuration: GIDConfiguration?
    
    public var user: GIDGoogleUser? {
        didSet {
            GoogleDrive.shared.configuration(with: user)
        }
    }
    
    public func configure(in bundle: Bundle = .main, for resource: String) {
        guard let path = bundle.path(forResource: resource, ofType: "plist"),
              let dictionary = NSDictionary(contentsOfFile: path),
              let clientID = dictionary.value(forKey: "CLIENT_ID") as? String else {
            return
        }
        configuration = GIDConfiguration(clientID: clientID)
    }
    
    public func signIn(with scopes: [Scope], callback: ((_ success: Bool, Error?) -> Void)?) {
        guard let clientID = configuration?.clientID,
              let viewController = UIApplication.topViewController() else {
            return
        }
        
        signIn(clientID: clientID, with: scopes, presenting: viewController, callback: callback)
    }
    
    public func signIn(clientID: String, with scopes: [Scope], callback: ((_ success: Bool, Error?) -> Void)?) {
        guard let viewController = UIApplication.topViewController() else {
            return
        }
        signIn(clientID: clientID, with: scopes, presenting: viewController, callback: callback)
    }
    
    public func signIn(clientID: String, with scopes: [Scope], presenting: UIViewController, callback: ((_ success: Bool, Error?) -> Void)?) {
        
        let configuration = GIDConfiguration(clientID: clientID)

        GIDSignIn
            .sharedInstance
            .signIn(with: configuration, presenting: presenting) { [weak self] user, error in
                guard !scopes.isEmpty else {
                    self?.user = user
                    callback?(user != nil, error)
                    return
                }
                self?.addScopes(scopes, presenting: nil) { _, error in
                    self?.restorePreviousSignIn { success, error in
                        callback?(success, error)
                    }
                }
            }
    }
    
    public func signOut() {
        GIDSignIn.sharedInstance.signOut()
    }
    
    public func restorePreviousSignIn(callback: ((_ success: Bool, Error?) -> Void)?) {
        GIDSignIn
            .sharedInstance
            .restorePreviousSignIn { [weak self] user, error in
                guard let error = error else {
                    self?.user = user
                    callback?(true, nil)
                    return
                }
                callback?(false, error)
            }
    }
    
    // AppDelegate GIDSingIn handle
    public func handle(_ url: URL) -> Bool {
        GIDSignIn.sharedInstance.handle(url)
    }
    
    
    func addScopes(_ scopes: [Scope], presenting: UIViewController?, callback: ((GIDGoogleUser?, Error?) -> Void)?) {
        guard let viewControllear = presenting ?? UIApplication.topViewController() else {
            callback?(nil, nil)
            return
        }
        let scopesPaths = scopes.map { $0.rawValue }
        
        GIDSignIn
            .sharedInstance
            .addScopes(scopesPaths, presenting: viewControllear) { user, error in
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
    public static let driveAppData = GoogleAuth.Scope(rawValue: "https://www.googleapis.com/auth/drive.appdata")
    public static let driveFile  = GoogleAuth.Scope(rawValue: "https://www.googleapis.com/auth/drive.file")
    public static let driveReadonly  = GoogleAuth.Scope(rawValue: "https://www.googleapis.com/auth/drive.readonly")
}


import Combine

extension GoogleAuth {
    
}




import UIKit

extension UIApplication {
    static func topViewController(controller: UIViewController? = nil) -> UIViewController? {
        let controller = controller ?? UIApplication.shared.windows.first { $0.isKeyWindow }?.rootViewController
        
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}
