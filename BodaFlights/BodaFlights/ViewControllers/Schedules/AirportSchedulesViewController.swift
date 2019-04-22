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
import RxDataSources
import DZNEmptyDataSet

class AirportSchedulesViewController: BaseViewController {
    @IBOutlet weak var tableView: UITableView!
    var viewModel: AirportSchedulesViewModel!
    var dataSource: RxTableViewSectionedReloadDataSource<ScheduleSection>!
    
    private let headerIdentifier = "ScheduleHeaderIdentifier"
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //Refresh control
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl!.rx
            .controlEvent(.valueChanged)
            .subscribe(onNext: { _ in
                self.fetchFirstPage()
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = R.segue.airportSchedulesViewController.toDetail(segue: segue)?.destination, let selectedSchedule = selectedSchedule {
            vc.schedule = selectedSchedule
        }
    }
    
    //MARK: -
    override func setupComponents() {
        //Navigations
        title = "\(viewModel.scheduleTitle)"
        addCloseButton()
        
        //TableView
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.register(R.nib.airportScheduleTableViewCell)
        tableView.register(UINib(resource: R.nib.scheduleHeaderView), forHeaderFooterViewReuseIdentifier: headerIdentifier)
        tableView.dataSource = nil
        tableView.delegate = self
        tableView.rowHeight = 100
        
        dataSource = RxTableViewSectionedReloadDataSource<ScheduleSection>(configureCell: { (ds, tbv, indexPath, item) -> AirportScheduleTableViewCell in
            let cell = tbv.dequeueReusableCell(withIdentifier: R.reuseIdentifier.airportScheduleTableViewCell, for: indexPath)!
            cell.selectionStyle = .none
            cell.configure(item: item)
            return cell
        })
        
        dataSource.titleForHeaderInSection = { ds, index in
            return ds.sectionModels[index].header
        }
        
        //
        //Selected cell
        tableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let `self` = self else { return }
                self.selectedSchedule = self.viewModel.schedule(at: indexPath.section)
                self.performSegue(withIdentifier: R.segue.airportSchedulesViewController.toDetail, sender: nil)
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
        output.dataSource.drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        //API error
        output.error.drive(onNext: { (error) in
            UIAlertController.presentOKAlertWithTitle(BodaError.ERROR_TITLE, message: error.localizedDescription)
            }, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)
        
        //Loading
        output.loading.drive(onNext: {[weak self] (loading) in
            if !loading {
                SVProgressHUD.dismiss()
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
        if let refreshControl = tableView.refreshControl {
            refreshControl.beginRefreshing()
        } else {
            SVProgressHUD.show()
        }
    }
}

//MARK: - UITableViewDelegate
extension AirportSchedulesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.backgroundView?.backgroundColor = UIColor.white
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let schedule = viewModel.schedule(at: section)
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: headerIdentifier) as! ScheduleHeaderView
        headerView.configure(item: schedule)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
}

// MARK: - DZNEmptyDataSetSource, DZNEmptyDataSetDelegate
extension AirportSchedulesViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "No flights available"
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byWordWrapping
        paragraph.alignment = .center
        let textFont = UIFont.BodaFonts.semiBoldS18
        let attributes = [NSAttributedString.Key.font: textFont,
                          NSAttributedString.Key.foregroundColor: UIColor.BodaColors.bodaTitle,
                          NSAttributedString.Key.paragraphStyle: paragraph]
        return NSAttributedString(string: text, attributes: attributes)
    }
}
