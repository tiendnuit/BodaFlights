//
//  AirportSearchViewController.swift
//  BodaFlights
//
//  Created by Scor Doan on 4/22/19.
//  Copyright © 2019 Scor Doan. All rights reserved.
//

import Foundation
import UIKit
import SVProgressHUD

class AirportSearchViewController: SearchBaseViewController {

    var onSelectedAirport: ((Airport) -> Void)?
    
    static func show() {
        let searchVC = R.storyboard.main.airportSearchViewController()!
        UIViewController.topMostController().present(searchVC, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func registerNibs() {
        // should register in subclass
        self.searchResultsTable.register(R.nib.airportTableViewCell)
    }
    
    override func setupSearchBar() {
        super.setupSearchBar()
        searchController.searchBar.placeholder = "Enter terminal, city or country..."
    }
    
    
    @IBAction func closeView() {
        if let nav = self.navigationController {
            nav.dismiss(animated: true, completion: nil)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    // MARK: - Searching methods
    override func search(text: String) {
        searchResults = PersistenceManager.shared.searchAirports(text)
    }
    
    override func canSearch(_ searchBar: UISearchBar) -> Bool {
        return !searchBar.text!.isEmpty
    }
    
    override func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        super.searchBar(searchBar, textDidChange: searchText)
    }

}

extension AirportSearchViewController {
    // MARK: - UITableViewDataSource & UITableViewDelegate
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let airport = self.searchResults[indexPath.row] as? Airport else{
            return UITableViewCell()
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.airportTableViewCell.identifier, for: indexPath) as! AirportTableViewCell
        cell.configure(item: airport)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let airport = searchResults[indexPath.row] as? Airport else{
            return
        }
        onSelectedAirport?(airport)
        searchBarCancelButtonClicked(searchController.searchBar)
        dismiss()
    }
}
