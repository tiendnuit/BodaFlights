//
//  Country.swift
//  BodaFlights
//
//  Created by Scor Doan on 4/21/19.
//  Copyright © 2019 Scor Doan. All rights reserved.
//

import Foundation

struct Country: Codable {
    var code: String
    private var lhName: LufthansaName
    var name: String {
        return lhName.value
    }
    enum CodingKeys: String, CodingKey {
        case code = "CountryCode"
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

extension Country: Equatable {
    static func == (lhs: Country, rhs: Country) -> Bool {
        return lhs.code == rhs.code
    }
}


//
struct CountryResponse {
    
    enum RootKeys: String, CodingKey {
        case countryResource = "CountryResource"
    }
    
    enum CountryResourceKeys: String, CodingKey {
        case countries = "Countries", meta = "Meta"
    }
    
    enum CountriesKeys: String, CodingKey {
        case country = "Country"
    }
    
    enum MetaKeys: String, CodingKey {
        case total = "TotalCount"
    }
    
    var countries:[Country] = []
    var totalCount: Int = 0
}

extension CountryResponse: Decodable {
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: RootKeys.self)
        let contriesContainer = try container.nestedContainer(keyedBy: CountryResourceKeys.self, forKey: .countryResource)
        //Get countries
        let contryContainer = try contriesContainer.nestedContainer(keyedBy: CountriesKeys.self, forKey: .countries)
        if let countries = try? contryContainer.decodeIfPresent([Country].self, forKey: .country) {
            self.countries = countries
        } else if let country = try? contryContainer.decodeIfPresent(Country.self, forKey: .country) {
            self.countries = [country]
        }
        
        //Get meta
        let metaContainer = try contriesContainer.nestedContainer(keyedBy: MetaKeys.self, forKey: .meta)
        if let total = try? metaContainer.decodeIfPresent(Int.self, forKey: .total) {
            totalCount = total
        }
    }
    
}
