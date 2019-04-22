//
//  Airport.swift
//  BodaFlights
//
//  Created by Scor Doan on 4/21/19.
//  Copyright © 2019 Scor Doan. All rights reserved.
//

import Foundation

//MARK: - Airport
class Airport: Codable {
    var code: String
    var cityCode: String
    var city: City?
    var countryCode: String
    var country: Country?
    var timezone: String
    
    //Airport name
    var name: String {
        return lhName.value
    }
    
    //Airport name and address
    var fullName: String {
        return [lhName.value, city?.name, country?.name].compactMap { $0 }.joined(separator: " ,")
    }
    
    //City, Country
    var address: String {
        return [city?.name, country?.name].compactMap { $0 }.joined(separator: " ,")
    }
    
    private var lhName: LufthansaName
    enum CodingKeys: String, CodingKey {
        case code = "AirportCode"
        case names = "Names"
        case cityCode = "CityCode"
        case city = "City"
        case countryCode = "CountryCode"
        case country = "Country"
        case timezone = "TimeZoneId"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        code = try container.decode(String.self, forKey: .code)
        
        //Name
        lhName = try container.decode(LufthansaName.self, forKey: .names)
        cityCode = try container.decode(String.self, forKey: .cityCode)
        city = try? container.decode(City.self, forKey: .city)
        countryCode = try container.decode(String.self, forKey: .countryCode)
        country = try? container.decode(Country.self, forKey: .country)
        timezone = try container.decode(String.self, forKey: .timezone)
        
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(code, forKey: .code)
        try container.encode(lhName, forKey: .names)
        try container.encode(cityCode, forKey: .cityCode)
        try container.encode(countryCode, forKey: .countryCode)
        try container.encode(timezone, forKey: .timezone)
        if let city = city {
            try container.encode(city, forKey: .city)
        }
        
        if let country = country {
            try container.encode(country, forKey: .country)
        }
    }
}

extension Airport: Equatable {
    static func == (lhs: Airport, rhs: Airport) -> Bool {
        return lhs.code == rhs.code
    }
}


// MARK: - City Response
struct AirportResponse {
    
    enum RootKeys: String, CodingKey {
        case airportResource = "AirportResource"
    }
    
    enum AirportResourceKeys: String, CodingKey {
        case airports = "Airports", meta = "Meta"
    }
    
    enum AirportsKeys: String, CodingKey {
        case airport = "Airport"
    }
    
    enum MetaKeys: String, CodingKey {
        case total = "TotalCount"
    }
    
    var airports:[Airport] = []
    var totalCount: Int = 0
}

extension AirportResponse: Decodable {
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: RootKeys.self)
        let airportsContainer = try container.nestedContainer(keyedBy: AirportResourceKeys.self, forKey: .airportResource)
        //Get airports
        let airportContainer = try airportsContainer.nestedContainer(keyedBy: AirportsKeys.self, forKey: .airports)
        if let airports = try? airportContainer.decodeIfPresent([Airport].self, forKey: .airport) {
            self.airports = airports
        } else if let airport = try? airportContainer.decodeIfPresent(Airport.self, forKey: .airport) {
            self.airports = [airport]
        }
        
        //Get meta
        let metaContainer = try airportsContainer.nestedContainer(keyedBy: MetaKeys.self, forKey: .meta)
        if let total = try? metaContainer.decodeIfPresent(Int.self, forKey: .total) {
            totalCount = total
        }
    }
    
}
