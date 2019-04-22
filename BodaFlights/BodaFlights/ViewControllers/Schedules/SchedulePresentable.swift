//
//  SchedulePresentable.swift
//  BodaFlights
//
//  Created by Scor Doan on 4/22/19.
//  Copyright © 2019 Scor Doan. All rights reserved.
//

import Foundation
import UIKit

protocol FlightPresentable {
    var flightNoLabel: BodaSemiBoldTitleLabel! {set get}
    var durationLabel: BodaSmallLightLabel! {set get}
    var departCodeLabel: UILabel! {set get}
    var departTimeLabel: UILabel! {set get}
    var arrivalCodeLabel: UILabel! {set get}
    var arrivalTimeLabel: UILabel! {set get}
    var transitLabel: UILabel! {set get}
}

extension FlightPresentable {
    func map(flight: Flight?) {
        guard let flight = flight else { return }
        
        flightNoLabel.text = "\(flight.number)"
        durationLabel.text = flight.duration
        departCodeLabel.text = flight.departureCode
        arrivalCodeLabel.text = flight.arrivalCode
        departTimeLabel.text = flight.departureTime?.toString(dateFormat: "hh:mma")
        arrivalTimeLabel.text = flight.arrivalTime?.toString(dateFormat: "hh:mma")
    }
}
