//
//  BaseViewController.swift
//  BodaFlights
//
//  Created by Scor Doan on 4/21/19.
//  Copyright © 2019 Scor Doan. All rights reserved.
//

import Foundation
import UIKit
import SVProgressHUD
import RxSwift

class BaseViewController: UIViewController, UIViewControllerConfigurable {
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupComponents()
    }
    
    //MARK: -
    func setupComponents() {
    }
    
    func bindViewModel() {
    }
    
    func updateUI() {
    }
}
