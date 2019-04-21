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
    private var pagingInfo = PaginationInfo(offset: 0, limit: 100)
    //Countries
    private var countries = [Country]()
    private var countryDict = [String: Country]()
    //Cities
    private var cities = [City]()       //using for testing
    private var cityDict = [String: City]()
    
    private var airports = [Airport]()
    
    var onUpdatedAirports: ((BodaError?) -> ())?
}

//MARK: -
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
                    loadFromDumpFile()
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
        //        if PersistenceManager.ALWAYS_LOAD_FROM_FILE || !FileManager.default.fileExists(atPath: sessionDataFilePath) {
        //            //Load from dump file
        //            loadFromDumpFile()
        //        } else {
        //            self.loadSessionsDataFromFile(url: URL(fileURLWithPath: sessionDataFilePath))
        //        }
        
        if FileManager.default.fileExists(atPath: airportsDataFilePath) {
            loadAirportsDataFromFile(url: URL(fileURLWithPath: airportsDataFilePath))
        }
    }
    
    func loadFromDumpFile() {
//        #if DEBUG
//        self.loadSessionsDataFromFile(url: R.file.dump_dataJson())
//        #endif
//        self.saveSessionsData()
    }
}

//MARK: - Load airports
extension PersistenceManager {

    //Load all countries
    func loadCountries() {
        pagingInfo.offset = countries.count
        lufthansaAPI.request(.countries(code: nil, pagingInfo: pagingInfo)) { [weak self] (result) in
            do {
                let response = try result.get()
                let countriesResponse = try response.map(CountryResponse.self)
                self?.countries.append(contentsOf: countriesResponse.countries)
                if self?.countries.count == countriesResponse.totalCount {
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
        //loadCities()
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
                if self?.cities.count == citiesResponse.totalCount {
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
        //updateCityOnAirports()
    }
    
    private func updateCityOnAirport(_ airport: Airport, completed: @escaping (() -> ())) {
        log.debug("===> Begin \(airport.cityCode)")
        guard airport.city == nil else {
            completed()
            return
        }
        if let city = cityDict[airport.cityCode] {
            airport.city = city
            completed()
            return
        }
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
        //Use semaphore to make sure doesn't meet Limit queries per seconds
//        let dispatchGroup = DispatchGroup()
//        let dispatchQueue = DispatchQueue(label: "com.gcd.updateCityOnAirportsQueue")
//        let dispatchSemaphore = DispatchSemaphore(value: 0)
//
//        dispatchQueue.async {
//            for airport in self.airports {
//                dispatchGroup.enter()
//                log.debug("===> Begin \(airport.cityCode)")
//                self.updateCityOnAirport(airport) {
//                    dispatchSemaphore.signal()
//                    dispatchGroup.leave()
//                    log.debug("===> End \(airport.cityCode)")
//                }
//                dispatchSemaphore.wait()
//            }
//        }
//
//        dispatchGroup.notify(queue: dispatchQueue) {
//            log.debug("===> Finish")
//            DispatchQueue.main.async { [weak self] in
//                self?.onUpdatedAirports?(nil)
//            }
//        }

        let group = DispatchGroup()
        var count = 0
        for airport in airports {
            group.enter()
            count += 1
            updateCityOnAirport(airport) {
                log.debug("===> End \(airport.cityCode)")
                group.leave()
            }
//            if count % 5 == 0 {
//                let delay = DispatchTime.now() + DispatchTimeInterval.seconds(1)
//                group.wait(timeout: delay)
//            }
        }

        group.notify(queue: DispatchQueue.main) { [weak self] in
            self?.saveAirportsData()
            self?.onUpdatedAirports?(nil)
        }

    }
    
    func updateAirportsInfo(_ completed: ((BodaError?) -> ())?) {
        //loadCountries()
        onUpdatedAirports = completed
        loadAirportsData()
        
    }
}
