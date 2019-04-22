//
//  ScheduleHeaderView.swift
//  BodaFlights
//
//  Created by Scor Doan on 4/22/19.
//  Copyright © 2019 Scor Doan. All rights reserved.
//

import Foundation
import UIKit

class ScheduleHeaderView: UITableViewHeaderFooterView, Configurable, SchedulePresentable {

    @IBOutlet weak var codeStackView: UIStackView!
    @IBOutlet weak var transitLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }

    func configure(item: Any) {
        map(schedule: item as? Schedule)
    }
}
