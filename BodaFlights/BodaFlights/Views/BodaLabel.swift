//
//  BodaLabel.swift
//  BodaFlights
//
//  Created by Scor Doan on 4/22/19.
//  Copyright © 2019 Scor Doan. All rights reserved.
//

import Foundation
import UIKit

class BodaLabel: UILabel {
    
    var titleFont : UIFont {
        return UIFont.BodaFonts.regS15
    }
    
    var titleColor : UIColor {
        return UIColor.BodaColors.bodaTitle
    }
    
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
        font = titleFont
        textColor = titleColor
    }
}

class BodaLargeTitleLabel: BodaLabel {
    override var titleFont: UIFont {
        return UIFont.BodaFonts.boldS20
    }
}

class BodaSemiBoldTitleLabel: BodaLabel {
    override var titleFont: UIFont {
        return UIFont.BodaFonts.semiBoldS18
    }
}

class BodaSmallLightLabel: BodaLabel {
    override var titleFont: UIFont {
        return UIFont.BodaFonts.regS11
    }
    
    override var titleColor : UIColor {
        return UIColor.BodaColors.lightGrayTitle
    }
}

class BodaSmallBoldLabel: BodaSmallLightLabel {
    override var titleFont: UIFont {
        return UIFont.BodaFonts.boldS11
    }
}

