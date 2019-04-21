//
//  ViewController.swift
//  BodaFlights
//
//  Created by Scor Doan on 4/20/19.
//  Copyright © 2019 Scor Doan. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    
    static func show() {
        let loginVC = R.storyboard.main.loginViewController()!
        UIViewController.topMostController().present(loginVC, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func requestTokenButtonClicked(_ sender: Any) {
        DataManager.shared.updateAccessToken { [weak self] error in
            if let error = error {
                UIAlertController.presentOKAlertWithTitle(BodaError.ERROR_TITLE, message: error.message)
            } else {
                self?.dismiss()
            }
        }
    }
    
}

