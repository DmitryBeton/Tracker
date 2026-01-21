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
        case .monday: return Localizable.WeekDay.monday.full.localized
        case .tuesday: return Localizable.WeekDay.tuesday.full.localized
        case .wednesday: return Localizable.WeekDay.wednesday.full.localized
        case .thursday: return Localizable.WeekDay.thursday.full.localized
        case .friday: return Localizable.WeekDay.friday.full.localized
        case .saturday: return Localizable.WeekDay.saturday.full.localized
        case .sunday: return Localizable.WeekDay.sunday.full.localized
        }
    }
    
    var shortName: String {
        switch self {
        case .monday: return Localizable.WeekDay.monday.short.localized
        case .tuesday: return Localizable.WeekDay.tuesday.short.localized
        case .wednesday: return Localizable.WeekDay.wednesday.short.localized
        case .thursday: return Localizable.WeekDay.thursday.short.localized
        case .friday: return Localizable.WeekDay.friday.short.localized
        case .saturday: return Localizable.WeekDay.saturday.short.localized
        case .sunday: return Localizable.WeekDay.sunday.short.localized
        }
    }
    
    static func fromDate(_ date: Date) -> WeekDay? {
        Calendar.current.weekDay(from: date)
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

