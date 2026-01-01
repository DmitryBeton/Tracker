//
//  ScheduleViewModel.swift
//  Tracker
//
//  Created by Дмитрий Чалов on 01.01.2026.
//

import Foundation
import Logging

protocol ScheduleViewModelProtocol: AnyObject {
    var onSelectedDaysChange: Binding<[WeekDay]>? { get set }
    var onScheduleReady: Binding<[WeekDay]>? { get set }
    
    func numberOfRows() -> Int
    func day(at index: Int) -> WeekDay?
    func isDaySelected(_ day: WeekDay) -> Bool
    func didToggleSwitch(at index: Int, isOn: Bool)
    func didTapDoneButton()
}

final class ScheduleViewModel: ScheduleViewModelProtocol {
    
    // MARK: - Dependencies
    private let logger = Logger(label: "ScheduleViewModel")
    private let model: ScheduleModel
    
    // MARK: - Bindings
    var onSelectedDaysChange: Binding<[WeekDay]>?
    var onScheduleReady: Binding<[WeekDay]>?
    
    // MARK: - Initialization
    init(for model: ScheduleModel = ScheduleModel()) {
        self.model = model
    }
    
    // MARK: - Public Methods
    func numberOfRows() -> Int {
        model.tableViewData.count
    }
    
    func day(at index: Int) -> WeekDay? {
        guard index >= 0 && index < model.tableViewData.count else {
            return nil
        }
        return model.tableViewData[index]
    }
    
    func isDaySelected(_ day: WeekDay) -> Bool {
        model.isDaySelected(day)
    }
    
    func didToggleSwitch(at index: Int, isOn: Bool) {
        guard let day = day(at: index) else {
            logger.error("❌ Некорректный индекс: \(index)")
            return
        }
        
        model.didToggleSwitch(for: day, isOn: isOn)
    }
    
    func didTapDoneButton() {
        let selectedDays = model.selectedDays
        logger.info("🔄 Передача расписания делегату.")
        
        onScheduleReady?(selectedDays)
        logger.info("🔒 Экран расписания закрывается")
    }
}
