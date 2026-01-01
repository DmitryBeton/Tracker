//
//  ScheduleModel.swift
//  Tracker
//
//  Created by Дмитрий Чалов on 01.01.2026.
//

import Foundation
import Logging

final class ScheduleModel {
    
    // MARK: - Properties
    private(set) var selectedDays: [WeekDay] = []
    let tableViewData: [WeekDay] = WeekDay.allCases
        
    // MARK: - Public Methods
    func isDaySelected(_ day: WeekDay) -> Bool {
        selectedDays.contains(day)
    }
    
    func didToggleSwitch(for day: WeekDay, isOn: Bool) {
        if isOn {
            if !selectedDays.contains(day) {
                selectedDays.append(day)
                selectedDays.sort { $0.rawValue < $1.rawValue }
            }
        } else {
            selectedDays.removeAll { $0 == day }
        }
    }
}
