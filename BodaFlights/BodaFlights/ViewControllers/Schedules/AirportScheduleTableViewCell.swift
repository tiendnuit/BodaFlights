//
//  AirportScheduleTableViewCell.swift
//  BodaFlights
//
//  Created by Scor Doan on 4/22/19.
//  Copyright © 2019 Scor Doan. All rights reserved.
//

import Foundation
import UIKit

class AirportScheduleTableViewCell: UITableViewCell, Configurable, FlightPresentable {
    // MARK: Properties
    @IBOutlet weak var flightNoLabel: BodaSemiBoldTitleLabel!
    @IBOutlet weak var durationLabel: BodaSmallLightLabel!
    @IBOutlet weak var departCodeLabel: UILabel!
    @IBOutlet weak var departTimeLabel: UILabel!
    @IBOutlet weak var arrivalCodeLabel: UILabel!
    @IBOutlet weak var arrivalTimeLabel: UILabel!
    
    func configure(item: Any) {
        map(flight: item as? Flight)
    }
}
