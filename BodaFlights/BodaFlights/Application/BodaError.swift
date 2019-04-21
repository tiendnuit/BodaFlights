//
//  BodaError.swift
//  BodaFlights
//
//  Created by Scor Doan on 4/20/19.
//  Copyright © 2019 Scor Doan. All rights reserved.
//

import Foundation

struct BodaError: Swift.Error, LocalizedError {
    var code: Int
    var message: String
    
    static let ERROR_TITLE = "Error"
    static var InvalidJson = BodaError(code: 0, message: "BodaError.InvalidJson")
    static var UnknownError = BodaError(code: 0, message: "BodaError.Unknown")
    static var UpdateAirportError = BodaError(code: 0, message: "BodaError.FailedToUpdateAirport")
    
    var errorDescription: String? {
        return message
    }
    
    static func error(_ error: Error) -> BodaError {
        return BodaError(code: 0, message: error.localizedDescription)
    }
}
