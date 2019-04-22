//
//  Schedule.swift
//  BodaFlights
//
//  Created by Scor Doan on 4/22/19.
//  Copyright © 2019 Scor Doan. All rights reserved.
//

import Foundation

class Schedule: Codable {
    var duration: String
    var flights: [Flight] = []

    enum CodingKeys: String, CodingKey {
        case totalJourney = "TotalJourney"
        case flight = "Flight"
    }
    
    enum TotalJourneyKeys: String, CodingKey {
        case duration = "Duration"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        //Duration
        let timeContainer = try container.nestedContainer(keyedBy: TotalJourneyKeys.self, forKey: .totalJourney)
        duration = try timeContainer.decode(String.self, forKey: .duration)
        
        if let flights = try? container.decode([Flight].self, forKey: .flight) {
            self.flights = flights
        } else if let flight = try? container.decode(Flight.self, forKey: .flight) {
            flights = [flight]
        }
        flights.forEach { $0.duration = duration }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var timeContainer = container.nestedContainer(keyedBy: TotalJourneyKeys.self, forKey: .totalJourney)
        try timeContainer.encode(duration, forKey: .duration)
        try container.encode(flights, forKey: .flight)
    }
}



// MARK: - City Response
struct ScheduleResponse {
    
    enum RootKeys: String, CodingKey {
        case scheduleResource = "ScheduleResource"
    }
    
    enum ResourceKeys: String, CodingKey {
        case schedule = "Schedule", meta = "Meta"
    }
    
    enum MetaKeys: String, CodingKey {
        case total = "TotalCount"
    }
    
    var schedules:[Schedule] = []
    var totalCount: Int = 0
}

extension ScheduleResponse: Decodable {
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: RootKeys.self)
        let resourceContainer = try container.nestedContainer(keyedBy: ResourceKeys.self, forKey: .scheduleResource)
        //Get Flights
        if let schedules = try? resourceContainer.decodeIfPresent([Schedule].self, forKey: .schedule) {
            self.schedules = schedules
        } else if let schedule = try? resourceContainer.decodeIfPresent(Schedule.self, forKey: .schedule) {
            self.schedules = [schedule]
        }
        
        //Get meta
        let metaContainer = try resourceContainer.nestedContainer(keyedBy: MetaKeys.self, forKey: .meta)
        if let total = try? metaContainer.decodeIfPresent(Int.self, forKey: .total) {
            totalCount = total
        }
    }
    
}
