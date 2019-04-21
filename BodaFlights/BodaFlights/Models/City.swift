//
//  City.swift
//  BodaFlights
//
//  Created by Scor Doan on 4/21/19.
//  Copyright © 2019 Scor Doan. All rights reserved.
//

import Foundation

//MARK: - City
struct City: Codable {
    var code: String
    private var lhName: LufthansaName
    var name: String {
        return lhName.value
    }
    enum CodingKeys: String, CodingKey {
        case code = "CityCode"
        case names = "Names"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        code = try container.decode(String.self, forKey: .code)
        
        //Name
        lhName = try container.decode(LufthansaName.self, forKey: .names)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(code, forKey: .code)
        try container.encode(lhName, forKey: .names)
    }
}

extension City: Equatable {
    static func == (lhs: City, rhs: City) -> Bool {
        return lhs.code == rhs.code
    }
}


// MARK: - City Response
struct CityResponse {
    
    enum RootKeys: String, CodingKey {
        case cityResource = "CityResource"
    }
    
    enum CityResourceKeys: String, CodingKey {
        case cities = "Cities", meta = "Meta"
    }
    
    enum CitiesKeys: String, CodingKey {
        case city = "City"
    }
    
    enum MetaKeys: String, CodingKey {
        case total = "TotalCount"
    }
    
    var cities:[City] = []
    var totalCount: Int = 0
}

extension CityResponse: Decodable {
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: RootKeys.self)
        let citiesContainer = try container.nestedContainer(keyedBy: CityResourceKeys.self, forKey: .cityResource)
        //Get countries
        let cityContainer = try citiesContainer.nestedContainer(keyedBy: CitiesKeys.self, forKey: .cities)
        if let cities = try? cityContainer.decodeIfPresent([City].self, forKey: .city) {
            self.cities = cities
        } else if let city = try? cityContainer.decodeIfPresent(City.self, forKey: .city) {
            self.cities = [city]
        }
        
        //Get meta
        let metaContainer = try citiesContainer.nestedContainer(keyedBy: MetaKeys.self, forKey: .meta)
        if let total = try? metaContainer.decodeIfPresent(Int.self, forKey: .total) {
            totalCount = total
        }
    }
    
}
