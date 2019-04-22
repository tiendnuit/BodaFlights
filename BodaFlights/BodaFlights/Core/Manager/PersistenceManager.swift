//
//  PersistenceManager.swift
//  BodaFlights
//
//  Created by Scor Doan on 4/21/19.
//  Copyright © 2019 Scor Doan. All rights reserved.
//

import Foundation
import SVProgressHUD

class PersistenceManager {
    
    static let shared = PersistenceManager()
    
    private var loadDataFromLocal = true        // Update aiports from LufthnasaAPI if false
    private var pagingInfo = PaginationInfo(offset: 0, limit: 100)
    //Countries
    private var countries = [Country]()
    private var countryDict = [String: Country]()
    //Cities
    private var cities = [City]()       //using for testing
    private var cityDict = [String: City]()
    
    private var airports = [Airport]()
    
    var onUpdatedAirports: ((BodaError?) -> ())?
    
    func searchAirports(_ searchText: String) -> [Airport] {
        return airports.filter { $0.fullName.lowercased().contains(searchText.lowercased()) }
    }
    
    func airport(from code: String) -> Airport? {
        if let index = airports.firstIndex(where: { $0.code == code }) {
            return airports[index]
        }
        return nil
    }
}

//MARK: - Load data from local
extension PersistenceManager {
    fileprivate func getDocumentsDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    fileprivate var airportsDataFilePath: String {
        let url = URL(fileURLWithPath: self.getDocumentsDirectory())
        return url.appendingPathComponent("airports_data").path
    }
    
    func loadAirportsDataFromFile(url: URL?) {
        if let url = url {
            if let data = try? Data(contentsOf: url) {
                let jsonDecoder = JSONDecoder()
                do {
                    let airports = try jsonDecoder.decode([Airport].self, from: data)
                    self.airports = airports
                    //updateCityOnAirports()
                    onUpdatedAirports?(nil)
                } catch {
                    //Load from dump file
                    loadAirportsDataFromFile(url: R.file.airports_data())
                }
            }
        }
    }
    
    func saveAirportsData() {
        // Transform array into data and save it into file
        let fileURL = URL(fileURLWithPath: airportsDataFilePath)
        let encoder = JSONEncoder()
        
        do {
            let data = try encoder.encode(airports)
            if FileManager.default.fileExists(atPath: fileURL.path) {
                try FileManager.default.removeItem(at: fileURL)
            }
            FileManager.default.createFile(atPath: fileURL.path, contents: data, attributes: nil)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func loadAirportsData() {
        //Check existed file
        if !FileManager.default.fileExists(atPath: airportsDataFilePath) {
            //Load from dump file
            loadAirportsDataFromFile(url: R.file.airports_data())
        } else {
            loadAirportsDataFromFile(url: URL(fileURLWithPath: airportsDataFilePath))
        }
    }
}

//MARK: - Load airports from Lufthansa API
extension PersistenceManager {

    //Load all countries
    func loadCountries() {
        pagingInfo.offset = countries.count
        lufthansaAPI.request(.countries(code: nil, pagingInfo: pagingInfo)) { [weak self] (result) in
            do {
                let response = try result.get()
                let countriesResponse = try response.map(CountryResponse.self)
                self?.countries.append(contentsOf: countriesResponse.countries)
                if self?.countries.count == countriesResponse.totalCount || countriesResponse.countries.isEmpty {
                    self?.loadedCountries()
                } else {
                    self?.loadCountries()
                }
            } catch let error {
                //error
                log.error(error)
                self?.onUpdatedAirports?(BodaError.UpdateAirportError)
            }
        }
    }
    
    private func loadedCountries() {
        countries.forEach { countryDict[$0.code] = $0 }
        loadAirports()
    }
    
    //Load all cities
    func loadCities() {
        pagingInfo.offset = cities.count
        lufthansaAPI.request(.cities(code: nil, pagingInfo: pagingInfo)) { [weak self] (result) in
            do {
                let response = try result.get()
                let citiesResponse = try response.map(CityResponse.self)
                self?.cities.append(contentsOf: citiesResponse.cities)
                if self?.cities.count == citiesResponse.totalCount || citiesResponse.cities.isEmpty {
                    self?.loadedCities()
                } else {
                    self?.loadCities()
                }
            } catch let error {
                //error
                log.error(error)
                self?.onUpdatedAirports?(BodaError.UpdateAirportError)
            }
        }
    }
    
    private func loadedCities() {
//        cities.forEach { cityCodeDict[$0.code] = $0.name }
//        DispatchQueue.main.async {
//            SVProgressHUD.dismiss()
//        }
    }
    
    //Load all airports
    func loadAirports() {
        pagingInfo.offset = airports.count
        lufthansaAPI.request(.airports(code: nil, pagingInfo: pagingInfo)) { [weak self] (result) in
            do {
                let response = try result.get()
                let airportsResponse = try response.map(AirportResponse.self)
                self?.airports.append(contentsOf: airportsResponse.airports)
                if self?.airports.count == airportsResponse.totalCount {
                    self?.loadedAirports()
                } else {
                    self?.loadAirports()
                }
            } catch let error {
                //error
                log.error(error)
                self?.onUpdatedAirports?(BodaError.UpdateAirportError)
            }
        }
    }
    
    private func loadedAirports() {
        airports.forEach { $0.country = countryDict[$0.countryCode]}
        saveAirportsData()
        updateCityOnAirports()
    }
    
    private func updateCityOnAirport(_ airport: Airport, completed: @escaping (() -> ())) {
        log.debug("===> Begin \(airport.cityCode)")
        lufthansaAPI.request(.cities(code: airport.cityCode, pagingInfo: PaginationInfo.default)) { [weak self] (result) in
            do {
                let response = try result.get()
                let citiesResponse = try response.map(CityResponse.self)
                if let city = citiesResponse.cities.first {
                    airport.city = city
                    self?.cityDict[airport.cityCode] = city
                }
                completed()
            } catch let error {
                //error
                log.error("===\(airport.cityCode)")
                log.error(error)
                self?.saveAirportsData()
                completed()
            }
        }
    }
    
    // Get city info on airport
    private func updateCityOnAirports() {
        let remainAirport = airports.filter { $0.city == nil }
        log.debug("===> Remain \(remainAirport.count)")
        if remainAirport.isEmpty {
            saveAirportsData()
            onUpdatedAirports?(nil)
            return
        }
        let group = DispatchGroup()
        //Limit 5 requests.
        var maxItems = 5
        for airport in remainAirport {
            if maxItems == 0 {
                break
            }
            if airport.city != nil {
                continue
            }
            if let city = cityDict[airport.cityCode] {
                airport.city = city
                continue
            }
            group.enter()
            maxItems -= 1
            updateCityOnAirport(airport) {
                log.debug("===> End \(airport.code) - \(maxItems)")
                group.leave()
            }
        }
        group.notify(queue: DispatchQueue.main) { [weak self] in
            self?.updateCityOnAirports()
        }
    }
    
    func updateAirportsInfo(_ completed: ((BodaError?) -> ())?) {
        onUpdatedAirports = completed

        if loadDataFromLocal {
            // Load airports from local file
            loadAirportsData()
        } else {
            // Load all countries -> load all airports -> update countries and city to the Airports.
            loadCountries()
        }
    }
}
