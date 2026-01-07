import UIKit
import Logging

final class TrackersViewModel {
    // MARK: - Bindings
    var onDataChanged: Binding<Void>?
    var onEmptyStateChanged: Binding<Bool>?
    
    // MARK: - Private properties
    private let dataProvider: DataProviderProtocol
    private let logger = Logger(label: "TrackersViewModel")
    
    private(set) var completedRecords: [TrackerRecord] = []
    private(set) var selectedDate: Date = Date()
    
    // MARK: - Initialization
    init(dataProvider: DataProviderProtocol) {
        self.dataProvider = dataProvider
    }
    
    // MARK: - Public API for ViewController
    var numberOfSections: Int {
        dataProvider.numberOfCategories
    }
    
    func numberOfItems(inSection section: Int) -> Int {
        dataProvider.numberOfTrackersInCategory(section)
    }
    
    func tracker(at indexPath: IndexPath) -> Tracker? {
        guard let cd = dataProvider.tracker(at: indexPath),
              let id = cd.id,
              let name = cd.name,
              let color = cd.color,
              let emoji = cd.emoji else { return nil }
        return Tracker(id: id, name: name, color: UIColorMarshalling.color(from: color), emoji: emoji)
    }
    
    func completedDays(for trackerId: UUID) -> Int {
        completedRecords.filter { $0.id == trackerId }.count
    }
    
    func isCompletedToday(trackerId: UUID) -> Bool {
        completedRecords.contains { $0.id == trackerId && Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
    }
    
    func categoryTitle(for section: Int) -> String {
        dataProvider.categoryTitle(at: section)
    }
    
    func reloadTrackers(for date: Date) {
        logger.info("called: \(#function)")
        selectedDate = date
        dataProvider.setDate(date)
        completedRecords = dataProvider.fetchCompletedRecords()
        onDataChanged?(())
        onEmptyStateChanged?(dataProvider.numberOfCategories == 0)
    }
    
    func toggleTrackerCompletion(for trackerId: UUID) -> Bool {
        logger.info("called: \(#function)")
        if selectedDate > Date() {
            return false // нельзя отмечать на будущие даты
        }
        dataProvider.toggleRecord(trackerId: trackerId, date: selectedDate)
        completedRecords = dataProvider.fetchCompletedRecords()
        onDataChanged?(())
        return true
    }
    
    func createNewTracker(_ tracker: Tracker, to category: String) {
        logger.info("called: \(#function)")
        do {
            try dataProvider.addTracker(tracker, to: category)
            logger.debug("✅ Tracker persisted")
        } catch {
            logger.error("❌ Error saving tracker: \(error)")
        }
        reloadTrackers(for: selectedDate)
    }
    
    func deleteTracker(_ tracker: UUID) {
        logger.info("called: \(#function)")
        do {
            try dataProvider.deleteTracker(tracker)
            logger.debug("✅ Tracker persisted")
        } catch {
            logger.error("❌ Error saving tracker: \(error)")
        }
        reloadTrackers(for: selectedDate)
    }
    
    func editTracker(_ tracker: Tracker) {
        logger.info("called: \(#function)")
        do {
            try dataProvider.editTracker(tracker)
            logger.debug("✅ Tracker persisted")
        } catch {
            logger.error("❌ Error saving tracker: \(error)")
        }
        reloadTrackers(for: selectedDate)
    }
    
    func indexPath(for trackerId: UUID) -> IndexPath? {
        logger.info("called: \(#function)")
        for section in 0..<dataProvider.numberOfCategories {
            for item in 0..<dataProvider.numberOfTrackersInCategory(section) {
                let indexPath = IndexPath(item: item, section: section)
                if dataProvider.tracker(at: indexPath)?.id == trackerId {
                    return indexPath
                }
            }
        }
        return nil
    }
    
    func filterTrackers(by filter: Filter) {
        if filter == .todayTrackers {
            dataProvider.setDate(Date())
        }
        dataProvider.setFilter(filter)
        filter == .todayTrackers ? reloadTrackers(for: Date()) : reloadTrackers(for: selectedDate)
        
    }
    
    func isFilterActive() -> Bool {
        let filter = dataProvider.getCurrentFilter()
        return filter != .allTrackers && filter != .todayTrackers
    }
    
    func getDataProvider() -> DataProviderProtocol {
        dataProvider
    }
}
