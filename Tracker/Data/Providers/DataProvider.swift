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
    // для отображения коллекции
    var numberOfCategories: Int { get }
    func categoryTitle(at index: Int) -> String
    func numberOfTrackersInCategory(_ section: Int) -> Int
    func tracker(at: IndexPath) -> TrackerCoreData?
    func fetchCompletedRecords() -> [TrackerRecord]
    
    // TrackerView Changes
    func setCurrentDate(_ date: Date)
    func setFilters(_ filters: [Filter])
    func toggleRecord(trackerId: UUID, date: Date)
    
    // CreateTracker
    func addTracker(_ tracker: Tracker, to: String) throws
    func deleteTracker(_ trackerId: UUID) throws
    func editTracker(_ tracker: Tracker) throws
    
    // CreateCategory
    func fetchAllCategories() -> [String]
    func addCategory(_ title: String) throws
    func deleteCategory(_ title: String) throws
    func editCategory(oldTitle: String, newTitle: String) throws
    
    func getCategoryTitle(for tracker: UUID) -> String
    func getSchedule(for tracker: UUID) -> [WeekDay]
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
    
    init(_ dataStore: DataStore) throws {
        guard let context = dataStore.managedObjectContext else {
            throw DataProviderError.failedToInitializeContext
        }
        self.context = context
        self.trackerStore = TrackerStore(context: context)
        self.trackerCategoryStore = TrackerCategoryStore(context: context)
        self.trackerRecordStore = TrackerRecordStore(context: context)
    }
    
    private func getPredicateForCurrentDate() -> NSPredicate? {
        logger.info("called: \(#function)")
        guard let currentWeekDay = WeekDay.fromDate(currentDate) else {
            logger.error("❌ Не удалось определить день недели для даты: \(currentDate)")
            return NSPredicate(value: false)
        }
        return createComplexPredicate(for: currentWeekDay)
    }
    
    private func createComplexPredicate(for weekDay: WeekDay) -> NSPredicate? {
        logger.info("called: \(#function)")
        let dayString = "\(weekDay.rawValue)"
        return NSPredicate(format: "schedule CONTAINS %@", dayString)
    }
    
    // Обновить предикат при смене даты
    private func updatePredicate() {
        logger.info("called: \(#function)")
        let predicate = getPredicateForCurrentDate()
        trackerStore.updateFetchedResultsControllerPredicate(predicate)
    }
}

// MARK: - DataProviderProtocol
extension DataProvider: DataProviderProtocol {
    func setFilters(_ filters: [Filter]) {
        // TODO: - Добавить смену Predicate, чтобы помимио даты сортирровка была по фильтрам
    }
    
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

    // MARK: - Other
    // Установить текущую дату и обновить фильтрацию
    func setCurrentDate(_ date: Date) {
        logger.info("called: \(#function)")
        self.currentDate = date
        updatePredicate()
    }
}
