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
        case .monday: "Понедельник"
        case .tuesday: "Вторник"
        case .wednesday: "Среда"
        case .thursday: "Четверг"
        case .friday: "Пятница"
        case .saturday: "Суббота"
        case .sunday: "Воскресенье"
        }
    }
    
    var shortName: String {
        switch self {
        case .monday: "Пн"
        case .tuesday: "Вт"
        case .wednesday: "Ср"
        case .thursday: "Чт"
        case .friday: "Пт"
        case .saturday: "Сб"
        case .sunday: "Вс"
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
