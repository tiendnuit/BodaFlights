//
//  Inlines.swift
//  BodaFlights
//
//  Created by Scor Doan on 4/21/19.
//  Copyright © 2019 Scor Doan. All rights reserved.
//

import Foundation

//MARK: -
let log = Logger.default

//MARK: -
func jsonCompatiblePayload(payload: [String : Any]) -> [String : Any] {
    var validPayload = [String : Any]()
    for key in payload.keys {
        guard var value = payload[key], (value is NSNull) == false else {
            continue
        }
        if let number = value as? Double {
            if number.isNaN || number.isInfinite {
                // skip
                continue
            }
            value = round(number * 100) / 100
        }
        if let number = value as? Float {
            if number.isNaN || number.isInfinite {
                // skip
                continue
            }
            value = roundf(number * 100) / 100
        }
        
        if let dict = value as? [String : Any] {
            validPayload[key] = jsonCompatiblePayload(payload: dict)
        } else {
            if let array = value as? [[String : Any]] {
                validPayload[key] = array.map({ jsonCompatiblePayload(payload: $0) })
            } else {
                validPayload[key] = value
            }
        }
    }
    return validPayload
}
