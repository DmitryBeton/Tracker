//
//  TrackerRepositoryMock.swift
//  Tracker
//
//  Created by Дмитрий Чалов on 08.11.2025.
//

import Foundation
import Logging

final class MockTrackersRepository: TrackerRepositoryProtocol {
    // MARK: - Properties
    private let logger = Logger(label: "MockTrackersRepository")

    private var categories: [TrackerCategory] = TrackersMockData.categories
    
    func fetchCategories() -> [TrackerCategory] {
        logger.info("📊 Запрос категорий: \(categories.count) категорий, \(categories.compactMap { $0.trackers }.count) трекеров")
        logger.debug("📋 Категории: \(categories.map { "\($0.title): \($0.trackers.count) трекеров" }.joined(separator: ", "))")

        return categories
    }

    func filteredCategories(for date: Date, from categories: [TrackerCategory]) -> [TrackerCategory] {
        let weekday = Calendar.current.component(.weekday, from: date)
        
        let currentWeekDay: WeekDay? = {
            switch weekday {
            case 1: return .sunday
            case 2: return .monday
            case 3: return .tuesday
            case 4: return .wednesday
            case 5: return .thursday
            case 6: return .friday
            case 7: return .saturday
            default: return nil
            }
        }()
        
        guard let currentWeekDay = currentWeekDay else {
            logger.error("❌ Неверный номер дня недели: \(weekday)")
            return []
        }
        
        return categories.compactMap { category in
            let filtered = category.trackers.filter { tracker in
                guard let schedule = tracker.schedule else { return true }
                return schedule.contains(currentWeekDay)
            }
            return filtered.isEmpty ? nil : TrackerCategory(title: category.title, trackers: filtered)
        }
    }
    
    // Добавляет трекер в categories
    func addTracker(_ tracker: Tracker, toCategory title: String) {
        // Ищем существующую категорию
        if let index = categories.firstIndex(where: { $0.title == title }) {
            var existingTrackers = categories[index].trackers
            existingTrackers.append(tracker)
            categories[index] = TrackerCategory(title: title, trackers: existingTrackers)
            logger.info("✅ Трекер добавлен в существующую категорию '\(title)'")
        } else {
            // Создаем новую категорию
            let newCategory = TrackerCategory(title: title, trackers: [tracker])
            categories.append(newCategory)
            logger.info("🆕 Создана новая категория '\(title)' с трекером '\(tracker.name)'")
        }
    }
}
