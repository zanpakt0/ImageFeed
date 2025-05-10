//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Zhukov Konstantin on 10.05.2025.
//

import Foundation

final class OAuth2TokenStorage {

     let tokenKey = "oauth_token"

    var token: String? {
        get {
            return UserDefaults.standard.string(forKey: tokenKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: tokenKey)
        }
    }
}
