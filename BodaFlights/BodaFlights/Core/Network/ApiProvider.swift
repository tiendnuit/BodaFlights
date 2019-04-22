//
//  ApiProvider.swift
//  BodaFlights
//
//  Created by Scor Doan on 4/22/19.
//  Copyright © 2019 Scor Doan. All rights reserved.
//

import Foundation
import Moya
import RxSwift
import RxCocoa

let lufthansaAPI = MoyaProvider<LufthansaAPI>(plugins: [NetworkLoggerPlugin(verbose: true)])

class ApiProvider {
    
    /** Returns Schedules list
     - Scope: Authenticated
     - Parameters:
     - origin: departures airport
     - destination: arrival airport
     - paginationInfo: paging infos
     
     - Returns:  schedule list
     - Throws:
     
     */
    static func schedules(origin: Airport, destination: Airport, paginationInfo: PaginationInfo) -> Observable<[Schedule]> {
        return Observable.create({ (observer) -> Disposable in
            lufthansaAPI.request(.schedules(origin: origin.code, destination: destination.code, fromDateTime: Date(), pagingInfo: paginationInfo), completion: { (result) in
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .formatted(DateFormatter.LufthansaDateFormatter)
                    let response = try result.get()
                    let scheduleResponse = try response.map(ScheduleResponse.self, using: decoder, failsOnEmptyData: true)
                    observer.onNext(scheduleResponse.schedules)
                    observer.onCompleted()
                    
                } catch let error {
                    //error
                    log.error(error)
                    observer.onNext([])
                    observer.onCompleted()
                }
            })
            return NopDisposable.instance
        })
    }
    
}


//MARK: - ===================================================
/**
 Represents a disposable that does nothing on disposal.
 Nop = No Operation
 */
public struct NopDisposable: Disposable {
    
    /**
     Singleton instance of `NopDisposable`.
     */
    public static let instance: Disposable = NopDisposable()
    
    init() {
        
    }
    
    /**
     Does nothing.
     */
    public func dispose() {
        
    }
}
