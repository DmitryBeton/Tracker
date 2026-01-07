//
//  TrackersViewModelTest.swift
//  Tracker
//
//  Created by Дмитрий Чалов on 07.01.2026.
//

import Foundation
@testable import Tracker

final class TrackersViewModelTest: TrackersViewModelProtocol {
    var onDataChanged: Binding<Void>?
    
    var onEmptyStateChanged: Binding<Bool>?
    
    var completedRecords: [TrackerRecord] = []
    
    var selectedDate: Date = Date()
    
    var numberOfSections: Int = 1
    
    func categoryTitle(for section: Int) -> String {
        "Важное"
    }
    
    func numberOfItems(inSection section: Int) -> Int {
        1
    }
    
    func tracker(at indexPath: IndexPath) -> Tracker? {
        Tracker(id: UUID(),name: "Текст", color: .ypBlue, emoji: "❄️")
    }
    
    func completedDays(for trackerId: UUID) -> Int {
        2
    }
    
    func isCompletedToday(trackerId: UUID) -> Bool {
        false
    }
    
    func toggleTrackerCompletion(for trackerId: UUID) -> Bool {
        false
    }
    
    func reloadTrackers(for date: Date) {
        
    }
    
    func createNewTracker(_ tracker: Tracker, to category: String) {
        
    }
    
    func deleteTracker(_ tracker: UUID) {
        
    }
    
    func editTracker(_ tracker: Tracker) {
        
    }
    
    func indexPath(for trackerId: UUID) -> IndexPath? {
        nil
    }
    
    func filterTrackers(by filter: Filter) {
        
    }
    
    func isFilterActive() -> Bool {
        false
    }
    
    func searchTrackers(with text: String?) {
        
    }
    
    func getDataProvider() -> DataProviderProtocol? {
        nil
    }
    
}
