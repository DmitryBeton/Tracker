//
//  DataProvider.swift
//  Tracker
//
//  Created by Дмитрий Чалов on 12.12.2025.
//

import UIKit
import CoreData
import Logging

protocol DataProviderProtocol {
    // CollectionView
    var numberOfCategories: Int { get }
    func categoryTitle(at index: Int) -> String
    func numberOfTrackersInCategory(_ section: Int) -> Int
    func tracker(at: IndexPath) -> TrackerCoreData?
    func fetchAllCategories() -> [String]
    func getCategoryTitle(for tracker: UUID) -> String

    // Add/Delete
    func addTracker(_ tracker: Tracker, to: String) throws
    func deleteTracker(_ trackerId: UUID) throws
    
    func addCategory(_ title: String) throws
    func deleteCategory(_ title: String) throws

    // Editing
    func editTracker(_ tracker: Tracker) throws
    func editCategory(oldTitle: String, newTitle: String) throws

    // Schedule
    func getSchedule(for tracker: UUID) -> [WeekDay]

    // Records
    func toggleRecord(trackerId: UUID, date: Date)
    func fetchCompletedRecords() -> [TrackerRecord]

    // Filter
    func setFilter(_ filter: Filter)
    func setDate(_ date: Date)
    func getCurrentFilter() -> Filter
}

// MARK: - DataProvider
final class DataProvider: NSObject {
    private let logger = Logger(label: "DataProvider")

    enum DataProviderError: Error {
        case failedToInitializeContext
    }

    private let context: NSManagedObjectContext
    private let trackerStore: TrackerStore
    private let trackerCategoryStore: TrackerCategoryStore
    private let trackerRecordStore: TrackerRecordStore
    
    private var currentDate: Date = Date()
    private var currentFilter: Filter = .allTrackers
    
    init(_ dataStore: DataStore) throws {
        guard let context = dataStore.managedObjectContext else {
            throw DataProviderError.failedToInitializeContext
        }
        self.context = context
        self.trackerStore = TrackerStore(context: context)
        self.trackerCategoryStore = TrackerCategoryStore(context: context)
        self.trackerRecordStore = TrackerRecordStore(context: context)
    }
}

// MARK: - DataProviderProtocol
extension DataProvider: DataProviderProtocol {
    func getSchedule(for tracker: UUID) -> [WeekDay] {
        do {
            print("получение расписания")
            return try trackerStore.getSchedule(for: tracker)
        } catch {
            print("ошибка сохраниеия")
            return []
        }
    }
    
    // MARK: - Categories
    func fetchAllCategories() -> [String] {
        var categories: [String] = []
        do {
            let categoriesCD = try trackerCategoryStore.fetchAllCategories()
            categories = categoriesCD.compactMap(\.title)
        } catch {
            print("ошибка загрузки категорий")
        }
        return categories
    }
    
    func getCategoryTitle(for tracker: UUID) -> String  {
        do {
            print("получение категории")
            return try trackerCategoryStore.getCategoryTitle(for: tracker)
        } catch {
            print("ошибка сохраниеия")
            return "Error: Category Not Found"
        }
    }
    
    func categoryTitle(at index: Int) -> String {
        guard let sections = trackerStore.fetchedResultsController.sections,
              index < sections.count else {
            print("⚠️ Секция \(index) не существует")
            return "Категория"
        }
        let sectionInfo = sections[index]
        guard let objects = sectionInfo.objects as? [TrackerCoreData],
              let firstObject = objects.first else {
            print("⚠️ Секция \(index) пустая")
            return "Категория \(index + 1)"
        }
        guard let categoryEntity = firstObject.category,
              let title = categoryEntity.title, !title.isEmpty
        else {
            print("⚠️ Ошибка получения трекера из секции \(index)")
            return "Без категории"
        }
        return title
    }
    
    func addCategory(_ title: String) {
        do {
            try trackerCategoryStore.createCategory(withTitle: title)
            print("успешно сохранили")


        } catch {
            print("ошибка сохраниеия")
        }
    }
    
    func deleteCategory(_ title: String) {
        do {
            try trackerCategoryStore.deleteCategory(withTitle: title)
            print("успешно сохранили")


        } catch {
            print("ошибка сохраниеия")
        }
    }
    
    func editCategory(oldTitle: String, newTitle: String) {
        do {
            try trackerCategoryStore.editCategory(withTitle: oldTitle, newTitle: newTitle)
            print("успешно сохранили")


        } catch {
            print("ошибка сохраниеия")
        }
    }
    
    var numberOfCategories: Int {
        return trackerStore.fetchedResultsController.sections?.count ?? 0
    }
    
    func numberOfTrackersInCategory(_ section: Int) -> Int {
        guard let sections = trackerStore.fetchedResultsController.sections,
              section < sections.count else {
            print("⚠️ Ошибка: запрошенной секции \(section) не существует")
            return 0
        }
        
        let numberOfObjects = sections[section].numberOfObjects
        return numberOfObjects
    }
    
    // MARK: - Records
    func fetchCompletedRecords() -> [TrackerRecord] {
        return (try? trackerRecordStore.fetchAllRecords()) ?? []
    }

    func toggleRecord(trackerId: UUID, date: Date) {
        logger.info("called: \(#function)")
        let day = Calendar.current.startOfDay(for: date)
        let records = fetchCompletedRecords()

        let exists = records.contains {
            $0.id == trackerId &&
            Calendar.current.isDate($0.date, inSameDayAs: day)
        }

        do {
            if exists {
                try trackerRecordStore.deleteRecord(trackerId: trackerId, date: day)
            } else {
                try trackerRecordStore.addRecord(trackerId: trackerId, date: day)
            }
        } catch {
            print("❌ Ошибка toggleRecord: \(error)")
        }
    }

    // MARK: - Trackers
    func tracker(at indexPath: IndexPath) -> TrackerCoreData? {
        guard let sections = trackerStore.fetchedResultsController.sections,
              indexPath.section < sections.count,
              indexPath.row < sections[indexPath.section].numberOfObjects else {
            print("❌ Ошибка: indexPath \(indexPath) вне границ")
            return nil
        }
        return trackerStore.fetchedResultsController.object(at: indexPath)
    }
    
    func addTracker(_ tracker: Tracker, to categoryTitle: String) throws {
        logger.info("called: \(#function)")
        let category = try trackerCategoryStore.findCategory(withTitle: categoryTitle)
        try trackerStore.addTracker(tracker, to: category)
    }
    
    func deleteTracker(_ trackerId: UUID) throws {
        do {
            try trackerStore.deleteTracker(trackerId)
            print("успешно сохранили")
        } catch {
            print("ошибка сохраниеия")
        }
    }
    
    func editTracker(_ tracker: Tracker) throws {
        do {
            try trackerStore.editTracker(tracker)
            print("успешно сохранили")
        } catch {
            print("ошибка сохраниеия")
        }
    }
}

// MARK: - Filters
extension DataProvider {
    func createPredicate(for filter: Filter, date: Date) -> NSPredicate? {
        logger.info("called: \(#function) filter: \(filter.rawValue), date: \(date)")
        
        switch filter {
        case .allTrackers:
            return createDatePredicate(for: date)
        case .todayTrackers:
            return createDatePredicate(for: date)
            
        case .completed:
            return createCompletedPredicate(for: date)
            
        case .notCompleted:
            return createNotCompletedPredicate(for: date)
        }
    }
    
    // MARK: - Private Methods for Create Predicate
    
    private func createDatePredicate(for date: Date) -> NSPredicate? {
        guard let weekDay = WeekDay.fromDate(date) else {
            logger.error("❌ Не удалось определить день недели для даты: \(date)")
            return NSPredicate(value: false)
        }
        
        let dayString = "\(weekDay.rawValue)"
        return NSPredicate(format: "schedule CONTAINS %@", dayString)
    }
    
    private func createCompletedPredicate(for date: Date) -> NSPredicate? {
        guard let datePredicate = createDatePredicate(for: date) else {
            return NSPredicate(value: false)
        }
        
        let completedTrackerIds = getCompletedTrackerIds(for: date)
        
        if completedTrackerIds.isEmpty {
            return NSPredicate(value: false)
        }
        
        let completedPredicate = NSPredicate(format: "id IN %@", completedTrackerIds)
        return NSCompoundPredicate(andPredicateWithSubpredicates: [datePredicate, completedPredicate])
    }
    
    private func createNotCompletedPredicate(for date: Date) -> NSPredicate? {
        guard let datePredicate = createDatePredicate(for: date) else {
            return NSPredicate(value: false)
        }
        
        let completedTrackerIds = getCompletedTrackerIds(for: date)
        
        if completedTrackerIds.isEmpty {
            return datePredicate
        }
        
        let notCompletedPredicate = NSPredicate(format: "NOT (id IN %@)", completedTrackerIds)
        return NSCompoundPredicate(andPredicateWithSubpredicates: [datePredicate, notCompletedPredicate])
    }
    
    private func getCompletedTrackerIds(for date: Date) -> [UUID] {
        let day = Calendar.current.startOfDay(for: date)
        let records = fetchCompletedRecords()
        
        return records
            .filter { Calendar.current.isDate($0.date, inSameDayAs: day) }
            .compactMap { $0.id }
    }
    
    // MARK: - Public Methods
    
    /// - Parameter filter: Выбранный фильтр
    func setFilter(_ filter: Filter) {
        logger.info("called: \(#function) with filter: \(filter.rawValue)")
        
        currentFilter = filter
        
        let predicate = createPredicate(for: filter, date: currentDate)
        trackerStore.updateFetchedResultsControllerPredicate(predicate)
        logger.info("✅ Filter applied: \(filter.rawValue), date: \(currentDate)")
    }
    
    /// - Parameter date: Новая дата
    func setDate(_ date: Date) {
        logger.info("called: \(#function) with date: \(date)")
        
        currentDate = date
        
        let predicate = createPredicate(for: currentFilter, date: date)
        trackerStore.updateFetchedResultsControllerPredicate(predicate)
 
        logger.info("✅ Date changed to: \(date), current filter: \(currentFilter.rawValue)")
    }
    
    func getCurrentFilter() -> Filter {
        return currentFilter
    }
    
    func getCurrentDate() -> Date {
        return currentDate
    }
    
    func resetFilter() {
        setFilter(.allTrackers)
    }
}
