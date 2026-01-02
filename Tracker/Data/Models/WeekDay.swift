//
//  Schedule.swift
//  Tracker
//
//  Created by Дмитрий Чалов on 03.11.2025.
//

import Foundation

enum WeekDay: Int, CaseIterable, Codable {
    case monday = 1
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday
    
    var fullName: String {
        switch self {
        case .monday: NSLocalizedString("monday_full", comment: "")
        case .tuesday: NSLocalizedString("tuesday_full", comment: "")
        case .wednesday: NSLocalizedString("wednesday_full", comment: "")
        case .thursday: NSLocalizedString("thursday_full", comment: "")
        case .friday: NSLocalizedString("friday_full", comment: "")
        case .saturday: NSLocalizedString("saturday_full", comment: "")
        case .sunday: NSLocalizedString("sunday_full", comment: "")
        }
    }
    
    var shortName: String {
        switch self {
        case .monday: NSLocalizedString("monday_short", comment: "")
        case .tuesday: NSLocalizedString("tuesday_short", comment: "")
        case .wednesday: NSLocalizedString("wednesday_short", comment: "")
        case .thursday: NSLocalizedString("thursday_short", comment: "")
        case .friday: NSLocalizedString("friday_short", comment: "")
        case .saturday: NSLocalizedString("saturday_short", comment: "")
        case .sunday: NSLocalizedString("sunday_short", comment: "")
        }
    }
    
    static func fromDate(_ date: Date) -> WeekDay? {
        return Calendar.current.weekDay(from: date)
    }
}

extension Calendar {
    func weekDay(from date: Date) -> WeekDay? {
        let weekday = component(.weekday, from: date)
        
        let mapping: [Int: WeekDay] = [
            2: .monday,
            3: .tuesday,
            4: .wednesday,
            5: .thursday,
            6: .friday,
            7: .saturday,
            1: .sunday
        ]
        
        return mapping[weekday]
    }
}
