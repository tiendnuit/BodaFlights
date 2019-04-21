//
//  BodaSearchBar.swift
//  BodaFlights
//
//  Created by Scor Doan on 4/22/19.
//  Copyright © 2019 Scor Doan. All rights reserved.
//

import Foundation
import UIKit

class BodaSearchBar : UISearchBar {
    
    init() {
        super.init(frame: CGRect.zero)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        changeSearchBarColor()
        
        cornerRadius = 8.0
        borderWidth = 1.0
        borderColor = .white
        barTintColor = .white
        backgroundColor = .white
        clipsToBounds = true
        contentMode = .scaleAspectFill
        backgroundImage = R.image.bgSearch()
    }
    
}

extension UISearchBar {
    
    func changeSearchBarColor(color : UIColor = UIColor.BodaColors.gray) {
        for subView in self.subviews {
            for subSubView in subView.subviews {
                
                if let _ = subSubView as? UITextInputTraits {
                    let textField = subSubView as! UITextField
                    textField.backgroundColor = color
                    break
                }
            }
        }
    }
}
