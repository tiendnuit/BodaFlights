//
//  UIStackView+Utility.swift
//  BodaFlights
//
//  Created by Scor Doan on 4/22/19.
//  Copyright © 2019 Scor Doan. All rights reserved.
//

import Foundation
import UIKit

extension UIStackView {
    
    func removeArrangedSubviews() {
        for subview in arrangedSubviews {
            removeArrangedSubview(subview)
        }
    }
}
