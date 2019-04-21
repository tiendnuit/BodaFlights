//
//  AppDefined.swift
//  BodaFlights
//
//  Created by Scor Doan on 4/20/19.
//  Copyright © 2019 Scor Doan. All rights reserved.
//

import Foundation

import UIKit

struct AppDefined {
    
    static func getStringValue(key: String) -> String {
        guard let info = Bundle.main.infoDictionary else { return ""}
        return info[key] as? String ?? ""
    }
    
    struct LufthansaApi {
        static var BaseUrl: String {
            return getStringValue(key: "LufthansaBaseURL")
        }
        
        static var ClientID: String {
            return getStringValue(key: "LufthansaClientID")
        }
        
        static var ClientSecret: String {
            return getStringValue(key: "LufthansaClientSecret")
        }
        
        static var Version: String {
            return getStringValue(key: "LufthansaApiVersion")
        }
        
        static let ITEMS_PER_PAGE = 20
        static let DEFAULT_LANGUAGE = "en"
    }
    
    enum UserDefault: String {
        case AccessToken = "AccessToken"
        case TokenType = "TokenType"
        case TokenExpired = "TokenExpired"
    }
}
