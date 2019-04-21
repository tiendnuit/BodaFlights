//
//  DataManager.swift
//  BodaFlights
//
//  Created by Scor Doan on 4/21/19.
//  Copyright © 2019 Scor Doan. All rights reserved.
//

import Foundation
import SVProgressHUD

class DataManager {
    
    static let shared = DataManager()
    var accessToken: String?
    var tokenType: String?
    var expiredDate: Date?
    
    var isLogged: Bool {
        guard let _ = accessToken, let _ = tokenType, let expiredDate = expiredDate  else {
            AppDelegate.shared.logout()
            return false
        }
        if expiredDate < Date() {
            AppDelegate.shared.logout()
            return false
        }
        return true
    }
    
    init() {
        accessToken = UserDefaults.string(forKey: .accessToken)
        tokenType = UserDefaults.string(forKey: .tokenType)
        expiredDate = UserDefaults.date(forKey: .tokenExpired)
    }
    
    func updateAccessToken(_ completed: ((BodaError?) -> ())?) {
        SVProgressHUD.show()
        lufthansaAPI.request(.accessToken) { [weak self] (result) in
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                do {
                    let response = try result.get()
                    let json = try response.mapJSON()
                    if let dict = json as? [String:Any] {
                        //success
                        log.debug(dict)
                        self?.updateCredentials(dict)
                        completed?(nil)
                    } else {
                        //error
                        log.error(BodaError.UnknownError)
                        completed?(BodaError.UnknownError)
                    }
                } catch let error {
                    //error
                    log.error(error)
                    completed?(BodaError.error(error))
                }
            }
        }
    }
    
    private func updateCredentials(_ dict: [String:Any]) {
        guard let accessToken = dict["access_token"] as? String,
            let tokenType = dict["token_type"] as? String,
            let expiresIn = dict["expires_in"] as? Double else {
                return
        }
        self.accessToken = accessToken
        self.tokenType = tokenType
        self.expiredDate = Date().addingTimeInterval(expiresIn)
        saveCredentials()
    }
    
    private func saveCredentials() {
        UserDefaults.setString(accessToken, forKey: .accessToken)
        UserDefaults.setString(tokenType, forKey: .tokenType)
        UserDefaults.setValue(expiredDate, forKey: .tokenExpired)
    }
    
    func logout() {
        accessToken = nil
        tokenType = nil
        saveCredentials()
    }
}
