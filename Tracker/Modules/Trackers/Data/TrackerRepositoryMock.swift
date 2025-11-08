//
//  TrackerRepositoryMock.swift
//  Tracker
//
//  Created by Дмитрий Чалов on 08.11.2025.
//

import Foundation

final class MockTrackersRepository: TrackerRepositoryProtocol {
    func fetchCategories() -> [TrackerCategory] {
        TrackersMockData.categories
    }

    func filteredCategories(for date: Date, from categories: [TrackerCategory]) -> [TrackerCategory] {
        let weekday = Calendar.current.component(.weekday, from: date)
        return categories.compactMap { category in
            let filtered = category.trackers.filter { tracker in
                guard let schedule = tracker.schedule else { return true }
                switch weekday {
                case 1: return schedule.sunday
                case 2: return schedule.monday
                case 3: return schedule.tuesday
                case 4: return schedule.wednesday
                case 5: return schedule.thursday
                case 6: return schedule.friday
                case 7: return schedule.saturday
                default: return false
                }
            }
            return filtered.isEmpty ? nil : TrackerCategory(title: category.title, trackers: filtered)
        }
    }
}
