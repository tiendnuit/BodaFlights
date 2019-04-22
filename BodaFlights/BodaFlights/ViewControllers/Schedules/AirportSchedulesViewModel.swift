//
//  AirportSchedulesViewModel.swift
//  BodaFlights
//
//  Created by Scor Doan on 4/22/19.
//  Copyright © 2019 Scor Doan. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class AirportSchedulesViewModel: ViewModelType {
    
    private var departureAirport: Airport!
    private var arrivalAirport: Airport!
    private var paginationInfo = PaginationInfo()
    private var schedules = [Schedule]()
    private var flights = [Flight]()
    
    var scheduleTitle: String {
        return "\(departureAirport.code) - \(arrivalAirport.code)"
    }
    var reachedBottom = false
    
    init(departureAirport: Airport, arrivalAirport: Airport) {
        self.departureAirport = departureAirport
        self.arrivalAirport = arrivalAirport
    }
    
    func transform(input: Input) -> Output {
        let activityIndicator = ActivityIndicator()
        let errorTracker = ErrorTracker()
        
        let getSchedules = input.loadSchedulesTrigger
            .flatMapLatest { _ -> SharedSequence<DriverSharingStrategy, [Schedule]> in
                self.paginationInfo.offset = self.schedules.count
                return ApiProvider.schedules(origin: self.departureAirport, destination: self.arrivalAirport, paginationInfo: self.paginationInfo)
                    .trackActivity(activityIndicator)
                    .trackError(errorTracker)
                    .asDriverOnErrorJustComplete()
            }.flatMap { (schedules) -> SharedSequence<DriverSharingStrategy, [Flight]> in
                self.reachedBottom = schedules.isEmpty
                self.schedules.append(contentsOf: schedules)
                self.flights.append(contentsOf: schedules.flatMap {$0.flights})
                return Observable.just(self.flights)
                    .asDriverOnErrorJustComplete()
            }
        
        
        return Output(dataSource: getSchedules,
                      error: errorTracker.asDriver(),
                      loading: activityIndicator.asDriver())
    }
    
    func reset() {
        schedules = []
        flights = []
        paginationInfo = PaginationInfo()
        reachedBottom = false
    }
    
    func canLoadMore(with indexPath: IndexPath) -> Bool {
        guard indexPath.row == flights.count - 1, reachedBottom == false else { return false }
        
        return true
    }
    
}

extension AirportSchedulesViewModel {
    struct Input {
        let loadSchedulesTrigger: Driver<Void>
    }
    
    struct Output {
        let dataSource: Driver<[Flight]>
        let error: Driver<Error>
        let loading:Driver<Bool>
    }
}
