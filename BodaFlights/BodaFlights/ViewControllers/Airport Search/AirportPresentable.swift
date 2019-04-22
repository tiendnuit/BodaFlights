//
//  AirportPresentable.swift
//  BodaFlights
//
//  Created by Scor Doan on 4/22/19.
//  Copyright © 2019 Scor Doan. All rights reserved.
//

import Foundation
import UIKit

protocol AirportPresentable {
    var nameLabel: BodaSemiBoldTitleLabel! {set get}
    var addressLabel: BodaSmallLightLabel! {set get}
}

extension AirportPresentable {
    func map(airport: Airport?) {
        guard let airport = airport else { return }
        
        nameLabel.text = airport.name
        addressLabel.text = airport.address
    }
}
