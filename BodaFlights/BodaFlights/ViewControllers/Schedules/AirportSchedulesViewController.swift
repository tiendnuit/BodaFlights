//
//  AirportSchedulesViewController.swift
//  BodaFlights
//
//  Created by Scor Doan on 4/22/19.
//  Copyright © 2019 Scor Doan. All rights reserved.
//

import Foundation
import UIKit
import SVProgressHUD
import RxSwift
import RxCocoa

class AirportSchedulesViewController: BaseViewController {
    @IBOutlet weak var tableView: UITableView!
    var viewModel: AirportSchedulesViewModel!
    
    private var selectedSchedule: Schedule?
    //MARK: - View cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        bindViewModel()
        updateUI()
        getSchedules()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    //MARK: -
    override func setupComponents() {
        //Navigations
        title = "\(viewModel.scheduleTitle)"
        addCloseButton()
        
        tableView.register(R.nib.airportScheduleTableViewCell)
        tableView.dataSource = nil
        tableView.rowHeight = 100
        //
        //Refresh control
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl!.rx
            .controlEvent(.valueChanged)
            .subscribe(onNext: { _ in
                self.fetchFirstPage()
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)
        
        
        //Selected cell
        tableView.rx.modelSelected(Schedule.self)
            .subscribe(onNext: { [weak self] feed in
                self?.selectedSchedule = feed
                //self?.performSegue(withIdentifier: R.segue.activityViewController.toDetail, sender: nil)
            }).disposed(by: disposeBag)
        
        //Reach bottom
        tableView.rx.willDisplayCell
            .subscribe(onNext: { [weak self] cellInfo in
                guard let `self` = self else { return }
                let (_, indexPath) = cellInfo
                
                if self.viewModel.canLoadMore(with: indexPath) {
                    let spinner = UIActivityIndicatorView(style: .gray)
                    spinner.startAnimating()
                    spinner.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: self.tableView.bounds.width, height: CGFloat(44))
                    
                    self.tableView.tableFooterView = spinner
                    self.tableView.tableFooterView?.isHidden = false
                    self.fetchNextPage()
                } else {
                    let label = UILabel(frame: CGRect(x: CGFloat(0), y: CGFloat(0), width: self.tableView.bounds.width, height: CGFloat(44)))
                    label.text = "You’re all caught up!"
                    label.textAlignment = .center
                    label.textColor = UIColor.BodaColors.lightGrayLine
                    label.font = UIFont.BodaFonts.regS11
                    self.tableView.tableFooterView = label
                    self.tableView.tableFooterView?.isHidden = false
                }
            })
            .disposed(by: disposeBag)
    }
    
    override func bindViewModel() {
        let loadSchedulesTrigger = rx.sentMessage(#selector(AirportSchedulesViewController.getSchedules))
            .mapToVoid()
            .asDriverOnErrorJustComplete()
        
        let input = AirportSchedulesViewModel.Input(loadSchedulesTrigger: loadSchedulesTrigger)
        let output = viewModel.transform(input: input)
        
        //Update tableview
        
        output.dataSource.drive(tableView.rx.items) { tableView, row, flight in
            let indexPath = IndexPath(row: row, section: 0)
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.airportScheduleTableViewCell, for: indexPath)!
            cell.configure(item: flight)
            return cell
            }.disposed(by: disposeBag)

        //API error
        output.error.drive(onNext: { (error) in
            UIAlertController.presentOKAlertWithTitle(BodaError.ERROR_TITLE, message: error.localizedDescription)
            }, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)
        
        //Loading
        output.loading.drive(onNext: {[weak self] (loading) in
            if !loading {
                self?.tableView.refreshControl?.endRefreshing()
            }
            }, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)
    }
    
    override func updateUI() {
        
    }
    
    func fetchFirstPage() {
        self.viewModel.reset()
        self.getSchedules()
    }
    
    private func fetchNextPage() {
        self.getSchedules()
    }
    
    @objc dynamic func getSchedules() {
        self.tableView.refreshControl?.beginRefreshing()
    }
}
