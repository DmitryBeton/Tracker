//
//  CreateTrackerModel.swift
//  Tracker
//
//  Created by Дмитрий Чалов on 01.01.2026.
//

import UIKit

final class EditTrackerModel {
    
    private let dataProvider: DataProviderProtocol
    private let tracker: Tracker
    
    init(dataProvider: DataProviderProtocol, trackerEditing: Tracker) {
        self.dataProvider = dataProvider
        self.tracker = trackerEditing
        
        let category = getCategory()
        let schedule = getSchedule()
        
        self.trackerData = TrackerEditedData()
            .withID(tracker.id)
            .withName(tracker.name)
            .withCategory(category)
            .withSchedule(schedule)
            .withEmoji(tracker.emoji)
            .withColor(tracker.color)
    }
    
    private let maxNameLength = 38
    let emojiItems = [
        "🙂", "😻", "🌺", "🐶", "❤️", "😱",
        "😇", "😡", "🥶", "🤔", "🙌", "🍔",
        "🥦", "🏓", "🥇", "🎸", "🏝️", "😪"
    ]
    
    let colorItems: [UIColor] = [
        .ypColorSelection1, .ypColorSelection2, .ypColorSelection3, .ypColorSelection4, .ypColorSelection5, .ypColorSelection6,
        .ypColorSelection7, .ypColorSelection8, .ypColorSelection9, .ypColorSelection10, .ypColorSelection11, .ypColorSelection12,
        .ypColorSelection13, .ypColorSelection14, .ypColorSelection15, .ypColorSelection16, .ypColorSelection17, .ypColorSelection18
    ]
    
    private(set) var trackerData = TrackerEditedData()
    
    private func getCategory() -> String {
        dataProvider.getCategoryTitle(for: tracker.id)
    }
    
    private func getSchedule() -> [WeekDay] {
        dataProvider.getSchedule(for: tracker.id)
    }
    
    func updateName(_ name: String) -> Result<String, CreateTrackerValidationError> {
        if name.count > maxNameLength {
            return .failure(.nameTooLong)
        }
        trackerData = trackerData.withName(name)
        return .success(name)
    }
    
    func updateCategory(_ category: String) -> Result<Void, CreateTrackerValidationError> {
        if category.isEmpty {
            return .failure(.categoryNotSelected)
        }
        trackerData = trackerData.withCategory(category)
        return .success(())
    }
    
    func updateSchedule(_ schedule: [WeekDay]) -> Result<Void, CreateTrackerValidationError> {
        if schedule.isEmpty {
            return .failure(.scheduleNotSelected)
        }
        trackerData = trackerData.withSchedule(schedule)
        return .success(())
    }
    
    func updateEmoji(_ emoji: String) -> Result<Void, CreateTrackerValidationError> {
        if emoji.isEmpty {
            return .failure(.emojiNotSelected)
        }
        trackerData = trackerData.withEmoji(emoji)
        return .success(())
    }
    
    func updateColor(_ color: UIColor) -> Result<Void, CreateTrackerValidationError> {
        if color == .clear {
            return .failure(.colorNotSelected)
        }
        trackerData = trackerData.withColor(color)
        return .success(())
    }
    
    func editTracker() -> Tracker? {
        guard !trackerData.name.isEmpty,
              !trackerData.category.isEmpty,
              let schedule = trackerData.schedule,
              !trackerData.emoji.isEmpty,
              trackerData.color != .clear else {
            return nil
        }
        return Tracker(
            id: trackerData.id,
            name: trackerData.name,
            color: trackerData.color,
            emoji: trackerData.emoji,
            schedule: schedule
        )
    }
    
    func isFormValid() -> Bool {
        return !trackerData.name.isEmpty &&
        !trackerData.category.isEmpty &&
        trackerData.schedule != nil &&
        !trackerData.emoji.isEmpty &&
        trackerData.color != .clear
    }
    
    func daysCompleted() -> [TrackerRecord] {
        dataProvider.fetchCompletedRecords()
    }
    
}
