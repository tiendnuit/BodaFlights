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
import RxSwift
import RxCocoa

class HomeViewController: BaseViewController {
    
    @IBOutlet weak var fromTextField: BodaTextField!
    @IBOutlet weak var toTextField: BodaTextField!
    @IBOutlet weak var searchButton: UIButton!
    
    private var searchingArrival = false
    private var departureAirport: Airport?
    private var arrivalAirport: Airport?
    
    
    //MARK: - View cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        updateUI()
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = R.segue.homeViewController.toSchedules(segue: segue)?.destination,
            let departureAirport = departureAirport,
            let arrivalAirport = arrivalAirport {
            vc.viewModel = AirportSchedulesViewModel(departureAirport: departureAirport, arrivalAirport: arrivalAirport)
        }
    }
    
    //MARK: -
    override func setupComponents() {
        //Navigations
        title = "BodaFlights"
        addLeftButton(image: nil, title: "Logout")
        
        fromTextField.textField.rx.controlEvent([.editingDidBegin])
            .subscribe { [weak self] text in
                self?.searchingArrival = false
                self?.showAirportSearch()
            }
            .disposed(by: disposeBag)
        
        toTextField.textField.rx.controlEvent([.editingDidBegin])
            .subscribe { [weak self] text in
                self?.searchingArrival = true
                self?.showAirportSearch()
            }
            .disposed(by: disposeBag)
    }
    
    override func updateUI() {
        fromTextField.text = departureAirport?.name ?? ""
        toTextField.text = arrivalAirport?.name ?? ""
        searchButton.isEnabled = (departureAirport != nil && arrivalAirport != nil)
        
    }
    
    override func leftButtonTapped() {
        let alert = UIAlertController.destructiveQuestionAlertWithTitle("Are you sure you want to logout?", message: nil, destructiveButtonTitle: "Logout") {
            AppDelegate.shared.logout()
        }
        present(alert, animated: true, completion: nil)
    }
    
    private func showAirportSearch() {
        view.endEditing(true)
        let searchVC = R.storyboard.main.airportSearchViewController()!
        searchVC.onSelectedAirport = { [weak self] airport in
            if self?.searchingArrival == true {
                self?.arrivalAirport = airport
            } else {
                self?.departureAirport = airport
            }
            self?.updateUI()
        }
        presentModally(viewController: searchVC)
    }
}
