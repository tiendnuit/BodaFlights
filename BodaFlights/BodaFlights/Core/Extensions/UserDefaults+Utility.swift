//
//  UserDefaults.swift
//  BodaFlights
//
//  Created by Scor Doan on 4/21/19.
//  Copyright © 2019 Scor Doan. All rights reserved.
//

import Foundation

extension UserDefaults {
    
    enum Key : String {
        case
        accessToken,
        tokenType,
        tokenExpired
    }
    
    // ----------------------------------------------------
    // MARK: - Checkers
    // ----------------------------------------------------
    
    static func isKeyPresentInUserDefaults(key: Key) -> Bool {
        return UserDefaults.standard.object(forKey: key.rawValue) != nil
    }
    
    // ----------------------------------------------------
    // MARK: - Setters
    // ----------------------------------------------------
    
    static func setDictionary(_ object: [String : Any], forKey key: Key) {
        UserDefaults.standard.set(jsonCompatiblePayload(payload: object), forKey: key.rawValue)
    }
    
    static func setBool(_ bool: Bool?, forKey key: Key) {
        UserDefaults.standard.set(bool, forKey: key.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    static func setString(_ string: String?, forKey key: Key) {
        UserDefaults.standard.set(string, forKey: key.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    static func setDate(_ date: Date?, forKey: Key) {
        UserDefaults.standard.set(date, forKey: forKey.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    static func setValue(_ value: Any?, forKey: Key) {
        UserDefaults.standard.set(value, forKey: forKey.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    // ----------------------------------------------------
    // MARK: - Getters
    // ----------------------------------------------------
    
    static func bool(forKey key: Key) -> Bool {
        return UserDefaults.standard.bool(forKey: key.rawValue)
    }
    
    static func string(forKey key: Key) -> String? {
        return UserDefaults.standard.string(forKey: key.rawValue)
    }
    
    static func integer(forKey key: Key) -> Int {
        return UserDefaults.standard.integer(forKey: key.rawValue)
    }
    
    static func double(forKey key: Key) -> Double {
        return UserDefaults.standard.double(forKey: key.rawValue)
    }
    
    static func float(forKey key: Key) -> Float {
        return UserDefaults.standard.float(forKey: key.rawValue)
    }
    
    static func date(forKey key: Key) -> Date? {
        return UserDefaults.standard.object(forKey: key.rawValue) as? Date
    }
    
    
    static func dictionary(forKey key: Key) -> [String : Any]? {
        return UserDefaults.standard.object(forKey: key.rawValue) as? [String : Any]
    }
}
