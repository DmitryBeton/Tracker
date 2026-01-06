//
//  CreateTrackerViewModel.swift
//  Tracker
//
//  Created by Дмитрий Чалов on 01.01.2026.
//

import UIKit

final class EditTrackerViewModel {
    
    // MARK: - Bindings
    var onNameStateChange: Binding<(text: String, warning: String?)?>?
    var onCreateButtonStateChange: Binding<Bool>?
    var onCategoryStateChange: Binding<String?>?
    var onScheduleStateChange: Binding<String?>?
    var onEmojiStateChange: Binding<String?>?
    var onColorStateChange: Binding<UIColor?>?

    // MARK: - Data for collection & table
    var emojiItems: [String] {
        model.emojiItems
    }
    
    var colorItems: [UIColor] {
        model.colorItems
    }
    
    var tableViewItems: [String] {
        [
            NSLocalizedString("category", comment: ""),
            NSLocalizedString("schedule", comment: "")
        ]
    }
    
    var sectionsTitles: [String] {
        [
            NSLocalizedString("emoji", comment: ""),
            NSLocalizedString("color", comment: "")
        ]
    }
    
    // MARK: - Current Properties
    var currentName: String? {
        model.trackerData.name
    }

    var currentCategory: String? {
        model.trackerData.category
    }
    
    var currentSchedule: [WeekDay]? {
        model.trackerData.schedule
    }
    
    var currentEmoji: String? {
        model.trackerData.emoji
    }
    
    var currentColor: UIColor? {
        model.trackerData.color
    }

    // MARK: - Dependencies
    private let model: EditTrackerModel
    
    // MARK: - Initialization
    init(for model: EditTrackerModel) {
        self.model = model
    }
    
    // MARK: - Public methods
    func didEnterName(_ name: String) {
        let result = model.updateName(name)
        
        switch result {
        case .success(let validatedName):
            onNameStateChange?((validatedName, nil))
            onCreateButtonStateChange?(model.isFormValid())
            
        case .failure(let error):
            onNameStateChange?((name, error.localizedDescription))
            onCreateButtonStateChange?(false)
        }
    }
    
    func didSelectCategory(_ category: String) {
        let result = model.updateCategory(category)
        
        switch result {
        case .success:
            onCategoryStateChange?(category)
            onCreateButtonStateChange?(model.isFormValid())
            
        case .failure:
            onCategoryStateChange?(nil)
            onCreateButtonStateChange?(false)
        }
    }
    
    func didSelectSchedule(_ schedule: [WeekDay]) {
        let result = model.updateSchedule(schedule)
        
        switch result {
        case .success:
            let scheduleText = formatScheduleText(schedule)
            onScheduleStateChange?(scheduleText)

            onCreateButtonStateChange?(model.isFormValid())
            
        case .failure:
            onScheduleStateChange?(nil)
            onCreateButtonStateChange?(false)
        }
    }

    func didSelectEmoji(_ emoji: String) {
        let result = model.updateEmoji(emoji)
        
        switch result {
        case .success:
            onEmojiStateChange?(emoji)
            onCreateButtonStateChange?(model.isFormValid())
            
        case .failure:
            onEmojiStateChange?(nil)
            onCreateButtonStateChange?(false)
        }
    }
    
    func didSelectColor(_ color: UIColor) {
        let result = model.updateColor(color)
        
        switch result {
        case .success:
            onColorStateChange?(color)
            onCreateButtonStateChange?(model.isFormValid())
            
        case .failure:
            onColorStateChange?(nil)
            onCreateButtonStateChange?(false)
        }
    }
    
    func editTracker() -> Tracker? {
        return model.editTracker()
    }
    
    private func formatScheduleText(_ schedule: [WeekDay]) -> String {
        if schedule.count == 7 {
            return NSLocalizedString("every_day", comment: "")
        } else {
            let sortedSchedule = schedule.sorted { $0.rawValue < $1.rawValue }
            return sortedSchedule.map { $0.shortName }.joined(separator: ", ")
        }
    }
    
    func displayedScheduleText(_ schedule: [WeekDay]?) -> String {
        guard let schedule else {
            return ""
        }
        if schedule.count == 7 {
            return NSLocalizedString("every_day", comment: "")
        } else {
            let sortedSchedule = schedule.sorted { $0.rawValue < $1.rawValue }
            return sortedSchedule.map { $0.shortName }.joined(separator: ", ")
        }

    }
    
    func daysCompleted() -> Int {
        let records = model.daysCompleted()
        let id = model.trackerData.id
        return records.filter { $0.id == id }.count
    }
}
