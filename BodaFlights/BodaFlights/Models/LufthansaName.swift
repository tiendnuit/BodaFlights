//
//  LufthansaName.swift
//  BodaFlights
//
//  Created by Scor Doan on 4/21/19.
//  Copyright © 2019 Scor Doan. All rights reserved.
//

import Foundation

struct LufthansaName: Codable {
    var value: String
    
    enum CodingKeys: String, CodingKey{
        case name = "Name"
    }
    
    enum ValueCodingKeys: String, CodingKey{
        case value = "$"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let nameContainer = try container.nestedContainer(keyedBy: ValueCodingKeys.self, forKey: .name)
        value = try nameContainer.decode(String.self, forKey: .value)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var nameContainer = container.nestedContainer(keyedBy: ValueCodingKeys.self, forKey: .name)
        try nameContainer.encode(value, forKey: .value)
    }
}

extension LufthansaName: Equatable {
    static func == (lhs: LufthansaName, rhs: LufthansaName) -> Bool {
        return lhs.value == rhs.value
    }
}
