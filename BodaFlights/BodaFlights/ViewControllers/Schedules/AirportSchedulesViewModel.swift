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
import RxDataSources

//MARK: -
struct ScheduleSection {
    var schedule: Schedule
    var header: String
    var items: [Flight]
    
    init(schedule: Schedule) {
        self.schedule = schedule
        self.header = ""
        self.items = schedule.flights
    }
}

extension ScheduleSection: SectionModelType {
    typealias Item = Flight
    
    init(original: ScheduleSection, items: [Item]) {
        self = original
        self.items = items
    }
    
//    init(original: ScheduleSection, schedule: Schedule) {
//        self = original
//        self.schedule = schedule
//        self.items = schedule.flights
//    }
}

//MARK: AirportSchedulesViewModel
final class AirportSchedulesViewModel: ViewModelType {
    
    private var departureAirport: Airport!
    private var arrivalAirport: Airport!
    private var paginationInfo = PaginationInfo()
    private var schedules = [ScheduleSection]()
    //private var flights = [Flight]()
    
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
            }.flatMap { (schedules) -> SharedSequence<DriverSharingStrategy, [ScheduleSection]> in
                self.reachedBottom = schedules.isEmpty
                let scheduleSections = schedules.map { ScheduleSection(schedule: $0) }
                self.schedules.append(contentsOf: scheduleSections)
                return Observable.just(self.schedules)
                    .asDriverOnErrorJustComplete()
            }
        
        
        return Output(dataSource: getSchedules,
                      error: errorTracker.asDriver(),
                      loading: activityIndicator.asDriver())
    }
    
    func reset() {
        schedules = []
        paginationInfo = PaginationInfo()
        reachedBottom = false
    }
    
    func schedule(at section: Int) -> Schedule {
        return schedules[section].schedule
    }
    
    func canLoadMore(with indexPath: IndexPath) -> Bool {
        //makre sure last section
        guard indexPath.section == schedules.count - 1, reachedBottom == false else { return false }
        
        let lastSection = schedules[indexPath.section]
        //make sure last row
        guard indexPath.row == lastSection.items.count - 1 else { return false }
        
        return true
    }
    
}

extension AirportSchedulesViewModel {
    struct Input {
        let loadSchedulesTrigger: Driver<Void>
    }
    
    struct Output {
        let dataSource: Driver<[ScheduleSection]>
        let error: Driver<Error>
        let loading:Driver<Bool>
    }
}
