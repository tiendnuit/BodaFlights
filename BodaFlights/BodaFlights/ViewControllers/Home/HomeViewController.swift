//
//  HomeViewController.swift
//  BodaFlights
//
//  Created by Scor Doan on 4/21/19.
//  Copyright © 2019 Scor Doan. All rights reserved.
//

import Foundation
import UIKit
import SVProgressHUD

class HomeViewController: BaseViewController {
    
    //MARK: - View cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !DataManager.shared.isLogged {
            log.debug("Show login")
        } else {
            SVProgressHUD.show()
            PersistenceManager.shared.updateAirportsInfo { (error) in
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                }

            }
        }
        
        
    }
    
    //MARK: -
    override func setupComponents() {
        //Navigations
        title = "BodaFlights"
        addLeftButton(image: nil, title: "Logout")
    }
    
    
    override func leftButtonTapped() {
        let alert = UIAlertController.destructiveQuestionAlertWithTitle("Are you sure you want to logout?", message: nil, destructiveButtonTitle: "Logout") {
            AppDelegate.shared.logout()
        }
        present(alert, animated: true, completion: nil)
    }
}
