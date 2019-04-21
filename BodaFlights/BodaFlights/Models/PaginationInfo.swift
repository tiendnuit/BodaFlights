//
//  PaginationInfo.swift
//  BodaFlights
//
//  Created by Scor Doan on 4/21/19.
//  Copyright © 2019 Scor Doan. All rights reserved.
//

import Foundation

public struct PaginationInfo {
    var offset: Int = 0
    var limit: Int = AppDefined.LufthansaApi.ITEMS_PER_PAGE
    var languague: String = AppDefined.LufthansaApi.DEFAULT_LANGUAGE
    
    var params: [String: Any] {
        return ["offset": offset, "limit": limit, "lang": languague]
    }
    
    init(offset: Int, limit: Int = AppDefined.LufthansaApi.ITEMS_PER_PAGE) {
        self.offset = offset
        self.limit = limit
    }
    
    static let `default` = PaginationInfo(offset: 0)
}
