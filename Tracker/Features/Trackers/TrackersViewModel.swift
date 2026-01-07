import UIKit
import Logging

protocol TrackersViewModelProtocol {
    var onDataChanged: Binding<Void>? { get set }
    var onEmptyStateChanged: Binding<Bool>? { get set }

    var completedRecords: [TrackerRecord] { get }
    var selectedDate: Date { get }
    
    var numberOfSections: Int { get }
    func categoryTitle(for section: Int) -> String
    func numberOfItems(inSection section: Int) -> Int
    func tracker(at indexPath: IndexPath) -> Tracker?
    
    func completedDays(for trackerId: UUID) -> Int
    func isCompletedToday(trackerId: UUID) -> Bool
    func toggleTrackerCompletion(for trackerId: UUID) -> Bool

    func reloadTrackers(for date: Date)
    
    func createNewTracker(_ tracker: Tracker, to category: String)
    func deleteTracker(_ tracker: UUID)
    func editTracker(_ tracker: Tracker)
    
    func indexPath(for trackerId: UUID) -> IndexPath?
    
    func filterTrackers(by filter: Filter)
    func isFilterActive() -> Bool
    func searchTrackers(with text: String?)

    func getDataProvider() -> DataProviderProtocol?
}

final class TrackersViewModel: TrackersViewModelProtocol {
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
    
    func getDataProvider() -> DataProviderProtocol? {
        dataProvider
    }
    
    // MARK: - Search
    func searchTrackers(with text: String?) {
        logger.info("called: \(#function)")
        dataProvider.setSearchText(text)
        reloadTrackers(for: selectedDate)
    }
}
