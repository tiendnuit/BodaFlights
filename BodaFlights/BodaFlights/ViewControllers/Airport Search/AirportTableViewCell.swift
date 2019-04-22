//
//  AirportTableViewCell.swift
//  BodaFlights
//
//  Created by Scor Doan on 4/22/19.
//  Copyright © 2019 Scor Doan. All rights reserved.
//

import Foundation
import UIKit

class AirportTableViewCell: UITableViewCell, Configurable, AirportPresentable {
    // MARK: Properties
    @IBOutlet weak var nameLabel: BodaSemiBoldTitleLabel!
    @IBOutlet weak var addressLabel: BodaSmallLightLabel!
    
    func configure(item: Any) {
        map(airport: item as? Airport)
    }
}
