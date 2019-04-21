//
//  BodaTextField.swift
//  BodaFlights
//
//  Created by Scor Doan on 4/21/19.
//  Copyright © 2019 Scor Doan. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

//MARK: - BodaBaseView
class BodaBaseView: UIView {
    
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
    }
}

//MARK: - BodaTextField
class BodaTextField: BodaBaseView {
    
    var keyboardType: UIKeyboardType = .default {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable var placeholder: String = "" {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable var text: String = "" {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable var isSecureTextEntry: Bool = false {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable var maxLenght: Int = 0
    
    var selected: Bool = false {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable var rightIconImage: UIImage? {
        didSet {
            updateView()
        }
    }
    
    private lazy var titleLabel : UILabel = {
        let textLabel = UILabel()
        textLabel.textColor = UIColor.BodaColors.lightGrayTitle
        textLabel.font = UIFont.BodaFonts.regS11
        textLabel.textAlignment = .left
        return textLabel
    }()
    
    private lazy var separateImageView: UIImageView! = {
        let imageView = UIImageView(image: nil)
        imageView.backgroundColor = UIColor.BodaColors.lightGrayLine
        return imageView
    }()
    
    lazy var textField: UITextField! = {
        let tf = UITextField()
        tf.borderStyle = .none
        tf.delegate = self
        tf.font = UIFont.BodaFonts.regS15
        tf.textColor = UIColor.BodaColors.brown
        return tf
    }()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, textField, separateImageView])
        stack.distribution = .fill
        stack.alignment = .fill
        stack.axis = .vertical
        stack.spacing = 5
        return stack
    }()
    
    func updateView() {
        //set right icon image
        if let rightIconImage = rightIconImage {
            textField.rightViewMode = .always
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
            imageView.contentMode = .scaleAspectFit
            imageView.image = rightIconImage
            textField.rightView = imageView
        } else {
            textField.rightViewMode = .never
        }
        
        //title
        textField.keyboardType = keyboardType
        textField.placeholder = placeholder
        textField.isSecureTextEntry = isSecureTextEntry
        textField.text = text
        titleLabel.text = placeholder
        //titleLabel.isHidden = text.isEmpty && !textField.isEditing
        
        let highlighted = textField.isEditing || !textField.text!.isEmpty
        titleLabel.textColor = highlighted ? UIColor.BodaColors.orange : UIColor.BodaColors.lightGrayTitle
        separateImageView.backgroundColor = highlighted ? UIColor.BodaColors.orange : UIColor.BodaColors.lightGrayTitle
        
        if text.isEmpty && !textField.isEditing {
            titleLabel.hideAnimated(in: stackView)
        } else {
            titleLabel.showAnimated(in: stackView)
        }
        
    }
    
    override func setup() {
        addSubview(stackView)
        textField.snp.makeConstraints { (maker) in
            maker.height.equalTo(40)
        }
        
        separateImageView.snp.makeConstraints { (maker) in
            maker.height.equalTo(1)
        }
        
        stackView.snp.makeConstraints { (maker) in
            maker.left.equalTo(self).offset(0)
            maker.right.equalTo(self).offset(0)
            maker.center.equalTo(self)
        }
        
    }
    
}

//MARK: - UITextFieldDelegate
extension BodaTextField: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        updateView()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        text = textField.text!
        updateView()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text, maxLenght > 0 else { return true }
        let count = text.count + string.count - range.length
        return count <= maxLenght
    }
}
