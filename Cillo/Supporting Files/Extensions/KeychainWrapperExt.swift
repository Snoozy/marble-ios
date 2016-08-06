//
//  KeychainWrapperExt.swift
//  Cillo
//
//  Created by Andrew Daley on 8/6/16.
//  Copyright © 2016 Cillo. All rights reserved.
//

import Foundation

extension KeychainWrapper {
    
    // MARK: - Constants
    
    /// Key to retrieve Auth_Token for the end user
    private let authKey = "Auth"
    
    /// Key to retrieve userID for the end user
    private let userIdKey = "User"
    
    // MARK: - Keychain Helper Functions
    
    /// :returns: Auth token for end user. Nil if none stored in keychain or error.
    class func authToken() -> String? {
        return KeychainWrapper.stringForKey(authKey)
    }
    
    /// Remove the stored auth token from the keychain.
    ///
    /// :returns: True if the auth token was successfully cleared.
    class func clearAuthToken() -> Bool {
        return KeychainWrapper.removeObjectForKey(authKey)
    }
    
    /// Remove the stored user ID from the keychain.
    ///
    /// :returns: True if the user ID was successfully cleared.
    class func clearUserId() -> Bool {
        return KeychainWrapper.removeObjectForKey(userIdKey)
    }
    
    /// Used to discover if keychain has values for keys .auth and .user
    ///
    /// :returns: True if there are values for both .auth and .user.
    class func hasAuthAndUser() -> Bool {
        guard let auth = KeychainWrapper.authToken(),
              let user = KeychainWrapper.userId() else {
            return false
        }
        return auth != "" && user != -1
    }
    
    /// Stores an auth token in the keychain.
    ///
    /// :param: token The auth token to be stored.
    /// :returns: True if the storage was successful.
    class func setAuthToken(token: String) -> Bool {
        return KeychainWrapper.setString(token, forKey: authKey)
    }
    
    /// Stores a user ID in the keychain.
    ///
    /// :param: id The id of the end user to be stored.
    /// :returns: True if the storage was successful.
    class func setUserID(_ id: Int) -> Bool {
        return KeychainWrapper.setObject(id, forKey: userIdKey)
    }
    
    /// :returns: User ID of end user. Nil if none stored in keychain or error.
    class func userId() -> Int? {
        return KeychainWrapper.objectForKey(userIdKey) as? Int
    }
}
