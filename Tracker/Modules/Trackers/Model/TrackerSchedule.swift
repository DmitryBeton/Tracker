//
//  Schedule.swift
//  Tracker
//
//  Created by Дмитрий Чалов on 03.11.2025.
//

enum WeekDay: String, CaseIterable, Codable {
    case monday = "Пн"
    case tuesday = "Вт"
    case wednesday = "Ср"
    case thursday = "Чт"
    case friday = "Пт"
    case saturday = "Сб"
    case sunday = "Вс"
    
    var fullName: String {
        switch self {
        case .monday: return "Понедельник"
        case .tuesday: return "Вторник"
        case .wednesday: return "Среда"
        case .thursday: return "Четверг"
        case .friday: return "Пятница"
        case .saturday: return "Суббота"
        case .sunday: return "Воскресенье"
        }
    }
}

struct TrackerSchedule {
    let selectedDays: Set<WeekDay>
    
    init(selectedDays: Set<WeekDay>) {
        self.selectedDays = selectedDays
    }
    
    func contains(_ day: WeekDay) -> Bool {
        return selectedDays.contains(day)
    }
}

extension TrackerSchedule {
    var displayText: String {
        if selectedDays.count == 7 {
            return "Каждый день"
        } else if selectedDays.isEmpty {
            return ""
        } else {
            let sortedDays = WeekDay.allCases.filter { selectedDays.contains($0) }
            return sortedDays.map { $0.rawValue }.joined(separator: ", ")
        }
    }
}
