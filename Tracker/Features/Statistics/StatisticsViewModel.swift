//
//  StatisticsViewModel.swift
//  Tracker
//
//  Created by Дмитрий Чалов on 07.01.2026.
//

import Foundation

final class StatisticsViewModel {
    private let dataProvider: DataProviderProtocol
    
    private let tableSourceData = [
        NSLocalizedString("best_period", comment: ""),
        NSLocalizedString("ideal_days", comment: ""),
        NSLocalizedString("trackers_completed", comment: ""),
        NSLocalizedString("average_value", comment: "")
    ]
    
    // MARK: - Initialization
    init(dataProvider: DataProviderProtocol) {
        self.dataProvider = dataProvider
    }
    
    func statInfo(for index: Int) -> (value: String, description: String) {
        switch index {
        case 0: return (getBestPeriod(), tableSourceData[0])
        case 1: return (getIdealDays(), tableSourceData[1])
        case 2: return (trackersCompleted(), tableSourceData[2])
        case 3: return (averageTrackersCompletion(), tableSourceData[3])
        default: return ("", "")
        }
    }
    
    var isEmpty: Bool {
        return (0..<tableSourceData.count).allSatisfy {
            statInfo(for: $0).value == "0"
        }
    }
    
    /// Лучший период: самая длинная серия последовательных завершений для любого трекера
    func getBestPeriod() -> String {
        let records = dataProvider.fetchCompletedRecords()
        let allTrackers = dataProvider.fetchAllTrackers()
        var maxStreak = 0
        for tracker in allTrackers {
            let trackerRecords = records
                .filter { $0.id == tracker.id }
                .map { Calendar.current.startOfDay(for: $0.date) }
                .sorted()
            var currentStreak = 1
            var bestStreak = 0
            if trackerRecords.count > 0 {
                for i in 1..<trackerRecords.count {
                    let prev = trackerRecords[i - 1]
                    let curr = trackerRecords[i]
                    if let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: prev),
                       Calendar.current.isDate(nextDay, inSameDayAs: curr) {
                        currentStreak += 1
                    } else {
                        bestStreak = max(bestStreak, currentStreak)
                        currentStreak = 1
                    }
                }
                bestStreak = max(bestStreak, currentStreak)
                maxStreak = max(maxStreak, bestStreak)
            }
        }
        return "\(maxStreak)"
    }
    
    /// Идеальные дни: количество дней, в течение которых все трекеры были завершены
    func getIdealDays() -> String {
        let records = dataProvider.fetchCompletedRecords()
        let allTrackers = dataProvider.fetchAllTrackers()
        if allTrackers.isEmpty { return "0" }
        
        var completionsByDay: [Date: Set<UUID>] = [:]
        for record in records {
            let day = Calendar.current.startOfDay(for: record.date)
            completionsByDay[day, default: []].insert(record.id)
        }
        
        let trackerIDs = Set(allTrackers.map { $0.id })
        let idealDaysCount = completionsByDay.values.filter { $0 == trackerIDs }.count
        return "\(idealDaysCount)"
    }
    
    /// Завершено отслеживание: общее количество завершений
    func trackersCompleted() -> String {
        let count = dataProvider.fetchCompletedRecords().count
        return "\(count)"
    }
    
    /// Среднее завершение: среднее количество завершений за активный день
    func averageTrackersCompletion() -> String {
        let records = dataProvider.fetchCompletedRecords()
        guard !records.isEmpty else { return "0" }
        
        let daysSet = Set(records.map { Calendar.current.startOfDay(for: $0.date) })
        let totalDays = daysSet.count
        guard totalDays > 0 else { return "0" }
        let average = Double(records.count) / Double(totalDays)
        
        let formatted = String(format: "%.1f", average)
        return formatted
    }
}
