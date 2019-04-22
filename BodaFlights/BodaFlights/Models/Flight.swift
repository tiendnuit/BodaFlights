//
//  Flight.swift
//  BodaFlights
//
//  Created by Scor Doan on 4/22/19.
//  Copyright © 2019 Scor Doan. All rights reserved.
//

import Foundation

class Flight: Codable {
    var number: Int
    var departureCode: String
    var departure: Airport?
    var arrivalCode: String
    var arrival: Airport?
    var departureTime: Date?
    var arrivalTime: Date?
    var duration: String = "n/a"
    //var equipment: String
    
    enum FlightKeys: String, CodingKey{
        case departure = "Departure",
        arrival = "Arrival",
        marketingCarrier = "MarketingCarrier"
    }
    
    enum AirportKeys: String, CodingKey{
        case airportCode = "AirportCode", scheduledTimeLocal = "ScheduledTimeLocal"
    }
    
    enum ScheduledTimeLocalKeys: String, CodingKey {
        case dateTime = "DateTime"
    }
    
    enum MarketingCarrierKeys: String, CodingKey {
        case flightNumber = "FlightNumber"
    }
    
    required init(from decoder: Decoder) throws {
        //Flight
        let flightContainer = try decoder.container(keyedBy: FlightKeys.self)
        //Departure
        let departureContainer = try flightContainer.nestedContainer(keyedBy: AirportKeys.self, forKey: .departure)
        departureCode = try departureContainer.decode(String.self, forKey: .airportCode)
        let departureTimeContainer = try departureContainer.nestedContainer(keyedBy: ScheduledTimeLocalKeys.self, forKey: .scheduledTimeLocal)
        departureTime = try departureTimeContainer.decode(Date.self, forKey: .dateTime)
        
        //Arrival
        let arrivalContainer = try flightContainer.nestedContainer(keyedBy: AirportKeys.self, forKey: .arrival)
        arrivalCode = try arrivalContainer.decode(String.self, forKey: .airportCode)
        let arrivalTimeContainer = try arrivalContainer.nestedContainer(keyedBy: ScheduledTimeLocalKeys.self, forKey: .scheduledTimeLocal)
        arrivalTime = try arrivalTimeContainer.decode(Date.self, forKey: .dateTime)
        
        //MarketingCarrier
        let marketingContainer = try flightContainer.nestedContainer(keyedBy: MarketingCarrierKeys.self, forKey: .marketingCarrier)
        number = try marketingContainer.decode(Int.self, forKey: .flightNumber)
        
        if let arrivalTime = arrivalTime, let departureTime = departureTime {
            duration = getTimeComponentString(olderDate: departureTime, newerDate: arrivalTime) ?? "n/a"
        }
    }
    
//    public func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        var nameContainer = container.nestedContainer(keyedBy: ValueCodingKeys.self, forKey: .name)
//        try nameContainer.encode(value, forKey: .value)
//    }
    
}

extension Flight: Equatable {
    static func == (lhs: Flight, rhs: Flight) -> Bool {
        return lhs.number == rhs.number
    }
}
