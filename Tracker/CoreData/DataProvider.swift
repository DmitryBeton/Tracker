//
//  DataProvider.swift
//  Tracker
//
//  Created by Дмитрий Чалов on 12.12.2025.
//

import UIKit
import CoreData
import Logging

struct NotepadStoreUpdate {
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
}

protocol DataProviderDelegate: AnyObject {
    func didUpdate(_ update: NotepadStoreUpdate)
}

protocol DataProviderProtocol {
    var numberOfCategories: Int { get }
    func numberOfTrackersInCategory(_ section: Int) -> Int
    func tracker(at: IndexPath) -> TrackerCoreData?
    func categoryTitle(at index: Int) -> String
    func addTracker(_ tracker: Tracker, to: String) throws
    func deleteRecord(at indexPath: IndexPath) throws
    
    func setCurrentDate(_ date: Date)
    
    func fetchCompletedRecords() -> [TrackerRecord]
    func toggleRecord(trackerId: UUID, date: Date)
}

// MARK: - DataProvider
final class DataProvider: NSObject {
    private let logger = Logger(label: "DataProvider")

    enum DataProviderError: Error {
        case failedToInitializeContext
    }
    
    weak var delegate: DataProviderDelegate?
    
    private let context: NSManagedObjectContext
    private let trackerStore: TrackerStore
    private let trackerCategoryStore: TrackerCategoryStore
    private let trackerRecordStore: TrackerRecordStore
    
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    
    private var currentDate: Date = Date()
    
    init(_ dataStore: DataStore, delegate: DataProviderDelegate) throws {
        guard let context = dataStore.managedObjectContext else {
            throw DataProviderError.failedToInitializeContext
        }
        self.delegate = delegate
        self.context = context
        self.trackerStore = TrackerStore(context: context)
        self.trackerCategoryStore = TrackerCategoryStore(context: context)
        self.trackerRecordStore = TrackerRecordStore(context: context)
    }
    
    // Метод для получения предиката фильтрации по текущей дате
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
    func fetchCompletedRecords() -> [TrackerRecord] {
        logger.info("called: \(#function)")
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

    var numberOfCategories: Int {
        logger.info("called: \(#function)")
        return trackerStore.fetchedResultsController.sections?.count ?? 0
    }
    
    func numberOfTrackersInCategory(_ section: Int) -> Int {
        logger.info("called: \(#function)")
        guard let sections = trackerStore.fetchedResultsController.sections,
              section < sections.count else {
            print("⚠️ Ошибка: запрошенной секции \(section) не существует")
            return 0
        }
        
        let numberOfObjects = sections[section].numberOfObjects
        return numberOfObjects
    }
    
    func tracker(at indexPath: IndexPath) -> TrackerCoreData? {
        logger.info("called: \(#function)")
        guard let sections = trackerStore.fetchedResultsController.sections,
              indexPath.section < sections.count,
              indexPath.row < sections[indexPath.section].numberOfObjects else {
            print("❌ Ошибка: indexPath \(indexPath) вне границ")
            return nil
        }
        return trackerStore.fetchedResultsController.object(at: indexPath)
    }
    
    func categoryTitle(at index: Int) -> String {
        logger.info("called: \(#function)")
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
    
    func addTracker(_ tracker: Tracker, to categoryTitle: String) throws {
        logger.info("called: \(#function)")
        let category = try trackerCategoryStore.findOrCreateCategory(withTitle: categoryTitle)
        try trackerStore.addTracker(tracker, to: category)
    }
    
    func deleteRecord(at indexPath: IndexPath) throws {
        logger.info("called: \(#function)")
        let trackerToDelete = trackerStore.fetchedResultsController.object(at: indexPath)
        try trackerStore.deleteTracker(trackerToDelete)
    }
    
    // Установить текущую дату и обновить фильтрацию
    func setCurrentDate(_ date: Date) {
        logger.info("called: \(#function)")
        self.currentDate = date
        updatePredicate()
    }
}
