//
//  SearchBaseViewController.swift
//  BodaFlights
//
//  Created by Scor Doan on 4/22/19.
//  Copyright © 2019 Scor Doan. All rights reserved.
//

import Foundation
import UIKit

class SearchBaseViewController: BaseViewController {
    //tableview
    @IBOutlet weak var searchResultsTable: UITableView!
    var searchController: UISearchController = UISearchController(searchResultsController: nil)
    
    var currentSearchText: String = "" //current page we are scrolling on
    var searchResults: [Any] = []{
        didSet{
            self.reloadData()
        }
    }
    var showCancelButton = true
    var isFirstSearch = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSearchBar()
        registerNibs()
        navigationController?.navigationBar.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.view.setNeedsLayout() // force update layout
        navigationController?.view.layoutIfNeeded() // to fix height of the navigation bar
        
        self.searchController.searchBar.resignFirstResponder()
        self.searchController.isActive = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showKeyboard()
        refreshSearchIfNeeded()
    }
    
    override func setupComponents() {
        searchResultsTable.delegate = self
        searchResultsTable.dataSource = self
    }
    
    func setupNavigationBar() {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        //        if let navBar = self.navigationController?.navigationBar {
        //            navBar.tintColor = UIColor.BodaColors.
        //        }
        //        self.navigationItem.hidesBackButton = true
    }
    
    @objc func showKeyboard() {
        self.searchController.isActive = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.searchController.searchBar.becomeFirstResponder()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reloadData() {
        self.searchResultsTable.reloadData()
    }
    
    func registerNibs() {
        // should register in subclass
    }
    
    func setupSearchBar(){
        self.definesPresentationContext = true
        searchController.definesPresentationContext = true
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Search"
        adjustTextInSearchBar()
        
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        
        navigationItem.titleView = searchController.searchBar
        self.searchController.searchBar.becomeFirstResponder()
        
        if let textfield = searchController.searchBar.value(forKey: "searchField") as? UITextField {
            textfield.font = UIFont.BodaFonts.regS15
            textfield.textColor = UIColor.BodaColors.bodaTitle
            if let backgroundview = textfield.subviews.first {
                backgroundview.layer.cornerRadius = 18
                backgroundview.layer.masksToBounds = true
            }
        }
        
    }
    
    
    func adjustTextInSearchBar() {
    }
    
    
    func search(text: String) {
        //Need to implement in inheritance class
    }
    
    func refreshSearchIfNeeded() {
        searchController.searchBar.text = self.currentSearchText
        if canSearch(searchController.searchBar){
            self.searchResults = []
            let text = searchController.searchBar.text ?? ""
            self.search(text: text)
        }
    }
    
    func isMoreThanTwoCharacter(_ searchBar: UISearchBar) -> Bool {
        return (searchBar.text?.count)! >= 2
    }
    
    // Using check some conditionals for searching
    func canSearch(_ searchBar: UISearchBar) -> Bool {
        return isMoreThanTwoCharacter(searchBar)
    }
    
    func hasSearchTextChanged(_ searchBar: UISearchBar) -> Bool{
        return self.currentSearchText != searchBar.text
    }
    
    func scheduledSearch(searchBar: UISearchBar) {
        
        let delay = 0.3 * Double(NSEC_PER_SEC)
        let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
        
        //the value of text is retained in the thread we spawn off main queue
        let text = searchBar.text ?? ""
        
        DispatchQueue.main.asyncAfter(deadline: time) {
            if text == searchBar.text {
                self.searchResults = []
                self.search(text: text)
            }
        }
    }
    
    @IBAction func didPressedStop(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}

//MARK: - UISearchBarDelegate & UISearchResultsUpdating
extension SearchBaseViewController: UISearchBarDelegate, UISearchResultsUpdating, UISearchControllerDelegate {
    
    //MARK: UISearchBarDelegate
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchController.searchBar.resignFirstResponder()
        if let _ = self.presentingViewController {
            self.dismiss(animated: true, completion: nil)
        } else if let nc = self.navigationController {
            nc.popViewController(animated: true)
        }
    }
    
    //SEARCH SCHEDULER
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.isFirstResponder &&
            canSearch(searchBar) &&
            hasSearchTextChanged(searchBar) {
            self.searchResults = []
            
            self.currentSearchText = searchBar.text!
            self.scheduledSearch(searchBar: searchBar)
        }
    }
    
    public func updateSearchResults(for searchController: UISearchController) {
        if searchController.isActive &&
            canSearch(searchController.searchBar) &&
            hasSearchTextChanged(searchController.searchBar) {
            self.searchResults = []
            
            self.currentSearchText = searchController.searchBar.text!
            self.scheduledSearch(searchBar: searchController.searchBar)
        }
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let text = searchBar.text {
            self.search(text: text)
        }
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(showCancelButton, animated: true)
        return true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(showCancelButton, animated: true)
    }
    
    func willPresentSearchController(_ searchController: UISearchController) {
        if !showCancelButton {
            searchController.searchBar.setValue("", forKey:"_cancelButtonText")
        }
        
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension SearchBaseViewController: UITableViewDataSource, UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
