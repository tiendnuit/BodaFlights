//
//  LufthansaAPI.swift
//  BodaFlights
//
//  Created by Scor Doan on 4/20/19.
//  Copyright © 2019 Scor Doan. All rights reserved.
//

import Foundation
import Moya

// MARK: - Provider setup

let lufthansaAPI = MoyaProvider<LufthansaAPI>(plugins: [NetworkLoggerPlugin(verbose: true)])

public enum LufthansaAPI {
    case accessToken
    case countries(code: String?, pagingInfo: PaginationInfo)
    case cities(code: String?, pagingInfo: PaginationInfo)
    case airports(code: String?, pagingInfo: PaginationInfo)
    case schedules(origin: String, destination: String, fromDateTime: Date, pagingInfo: PaginationInfo)
}

extension LufthansaAPI: TargetType {
    public var baseURL: URL {
        let path = AppDefined.LufthansaApi.BaseUrl + AppDefined.LufthansaApi.Version
        return URL(string: path)!
    }
    public var path: String {
        switch self {
        case .accessToken:
            return "/oauth/token"
        case .countries(let code, _):
            if let code = code {
                return "/references/countries/\(code)"
            }
            return "/references/countries"
        case .cities(let code, _):
            if let code = code {
                return "/references/cities/\(code)"
            }
            return "/references/cities"
        case .airports(let code, _):
            if let code = code {
                return "/references/airports/\(code)"
            }
            return "/references/airports"
        case .schedules:
            return "/operations/schedules"

        }
    }

    public var method: Moya.Method {
        switch self {
        case .accessToken:
            return .post
        default:
            return .get
        }
    }

    public var task: Task {
        switch self {
        case .accessToken:
            let params = ["client_id": AppDefined.LufthansaApi.ClientID,
                          "client_secret": AppDefined.LufthansaApi.ClientSecret,
                          "grant_type": "client_credentials"]
            return .requestParameters(parameters: params, encoding: parameterEncoding)
        case .countries(_, let pagingInfo):
            return .requestParameters(parameters: pagingInfo.params, encoding: parameterEncoding)

        case .cities(_, let pagingInfo):
            return .requestParameters(parameters: pagingInfo.params, encoding: parameterEncoding)

        case .airports(_, let pagingInfo):
            return .requestParameters(parameters: pagingInfo.params, encoding: parameterEncoding)
            
        default:
            return .requestPlain
        }
    }

    public var sampleData: Data {
        return Data()
    }

    public var parameterEncoding: ParameterEncoding {
        switch self {
//        case .accessToken:
//            return JSONEncoding.default
        default:
            return URLEncoding.default
        }
    }

    public var headers: [String: String]? {
        switch self {
        case .accessToken:
            return ["Content-Type": "application/x-www-form-urlencoded"]
        default:
            var params = ["Content-Type": "application/json", "Accept": "application/json"]
            if let accessToken = DataManager.shared.accessToken {
                params["Authorization"] = "Bearer \(accessToken)"
            }
            
            return params
        }
        
    }
}

public func url(_ route: TargetType) -> String {
    return route.baseURL.appendingPathComponent(route.path).absoluteString
}
