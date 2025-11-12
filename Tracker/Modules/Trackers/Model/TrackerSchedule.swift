//
//  Schedule.swift
//  Tracker
//
//  Created by Дмитрий Чалов on 03.11.2025.
//

struct TrackerSchedule {
    let monday: Bool
    let tuesday: Bool
    let wednesday: Bool
    let thursday: Bool
    let friday: Bool
    let saturday: Bool
    let sunday: Bool
}

extension TrackerSchedule {
    var displayText: String {
        let days = [
            (monday, "Пн"),
            (tuesday, "Вт"),
            (wednesday, "Ср"),
            (thursday, "Чт"),
            (friday, "Пт"),
            (saturday, "Сб"),
            (sunday, "Вс")
        ]
        
        let selectedDays = days.filter { $0.0 }.map { $0.1 }
        
        if selectedDays.count == 7 {
            return "Каждый день"
        } else if selectedDays.isEmpty {
            return ""
        } else {
            return selectedDays.joined(separator: ", ")
        }
    }
}
