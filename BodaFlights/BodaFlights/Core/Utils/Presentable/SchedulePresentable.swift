//
//  SchedulePresentable.swift
//  BodaFlights
//
//  Created by Scor Doan on 4/22/19.
//  Copyright © 2019 Scor Doan. All rights reserved.
//

import Foundation
import UIKit

protocol SchedulePresentable {
    var codeStackView: UIStackView! {set get}
    var transitLabel: UILabel! {set get}
}

extension SchedulePresentable {
    func map(schedule: Schedule?) {
        guard let schedule = schedule else { return }
        
        let transits = schedule.flights.count - 1
        transitLabel.text = "Transit: \(transits)"
        
        codeStackView.subviews.forEach { $0.removeFromSuperview() }
        var codes = schedule.flights.map { $0.departureCode }
        if let lastFlight = schedule.flights.last {
            codes.append(lastFlight.arrivalCode)
        }
        
        for code in codes {
            let label = BodaSmallBoldLabel()
            label.text = code
            codeStackView.addArrangedSubview(label)
            
            if let last = codes.last, last != code {
                let image = UIImageView(image: R.image.iconFlight()!)
                image.contentMode = .center
                codeStackView.addArrangedSubview(image)
            }
        }
    }
    
}
