//
//  NotepadStoreUpdate.swift
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
    private let dataStore: TrackerDataStore
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        
        let predicate = getPredicateForCurrentDate()
        fetchRequest.predicate = predicate
        
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "category.title", ascending: true),
            NSSortDescriptor(key: "name", ascending: true)
        ]
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: "category.title",
            cacheName: nil
        )
        
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        
        return fetchedResultsController
    }()

    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    
    private var currentDate: Date = Date()
    private let uiColorMarshalling = UIColorMarshalling.shared
    
    init(_ dataStore: TrackerDataStore, delegate: DataProviderDelegate) throws {
        guard let context = dataStore.managedObjectContext else {
            throw DataProviderError.failedToInitializeContext
        }
        self.delegate = delegate
        self.context = context
        self.dataStore = dataStore
    }
    
    // Метод для получения предиката фильтрации по текущей дате
    private func getPredicateForCurrentDate() -> NSPredicate? {
        logger.info("called: \(#function) \(#line)")
        guard let currentWeekDay = WeekDay.fromDate(currentDate) else {
            logger.error("❌ Не удалось определить день недели для даты: \(currentDate)")
            return NSPredicate(value: false)
        }
        // Проблема: schedule хранится как Data, нельзя фильтровать через contains
        // Поэтому фильтруем вручную в shouldDisplayTracke
         return createComplexPredicate(for: currentWeekDay)
    }
    
    private func createComplexPredicate(for weekDay: WeekDay) -> NSPredicate? {
        logger.info("called: \(#function) \(#line)")
        // Сложный предикат для фильтрации в CoreData
        // Работает только если schedule хранится как String, а не Data
        
        // Конвертируем WeekDay в строку для поиска
        let dayString = "\(weekDay.rawValue)"
        
        // Ищем JSON строку, содержащую этот номер дня
        // Пример: schedule содержит "[1,3,5]" - ищем "1" или ",1," или "[1" или "1]"
        return NSPredicate(format: "schedule CONTAINS %@", dayString)
    }
    
    // Обновить предикат при смене даты
    private func updatePredicate() {
        logger.info("called: \(#function) \(#line)")
        let predicate = getPredicateForCurrentDate()
        fetchedResultsController.fetchRequest.predicate = predicate
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("❌ Ошибка обновления предиката: \(error)")
        }
    }
}

// MARK: - DataProviderProtocol
extension DataProvider: DataProviderProtocol {
    func fetchCompletedRecords() -> [TrackerRecord] {
        logger.info("called: \(#function)")
        return (try? dataStore.fetchRecords()) ?? []
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
                try dataStore.deleteRecord(trackerId: trackerId, date: day)
            } else {
                try dataStore.addRecord(trackerId: trackerId, date: day)
            }
        } catch {
            print("❌ Ошибка toggleRecord: \(error)")
        }
    }

    var numberOfCategories: Int {
        logger.info("called: \(#function)")
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func numberOfTrackersInCategory(_ section: Int) -> Int {
        logger.info("called: \(#function)")
        // ВАЖНО: Проверяем существование секции
        guard let sections = fetchedResultsController.sections,
              section < sections.count else {
            print("⚠️ Ошибка: запрошенной секции \(section) не существует")
            return 0
        }
        
        let numberOfObjects = sections[section].numberOfObjects
        return numberOfObjects
    }
    
    func tracker(at indexPath: IndexPath) -> TrackerCoreData? {
        logger.info("called: \(#function)")
        // ВАЖНО: Проверяем валидность indexPath
        guard let sections = fetchedResultsController.sections,
              indexPath.section < sections.count,
              indexPath.row < sections[indexPath.section].numberOfObjects else {
            print("❌ Ошибка: indexPath \(indexPath) вне границ")
            return nil
        }
        return fetchedResultsController.object(at: indexPath)
    }
    
    func categoryTitle(at index: Int) -> String {
        logger.info("called: \(#function)")
        guard let sections = fetchedResultsController.sections,
              index < sections.count else {
            print("⚠️ Секция \(index) не существует")
            return "Категория"
        }
        let sectionInfo = sections[index]
        // 2. Получаем первый трекер в секции
        guard let objects = sectionInfo.objects as? [TrackerCoreData],
              let firstObject = objects.first else {
            print("⚠️ Секция \(index) пустая")
            return "Категория \(index + 1)"
        }
        // 3. Получаем связанную категорию
        guard let categoryEntity = firstObject.category,
              let title = categoryEntity.title, !title.isEmpty
        else {
            print("⚠️ Ошибка получения трекера из секции \(index)")
            return "Без категории"
        }
        return title
    }
    
    func addTracker(_ tracker: Tracker, to: String) throws {
        logger.info("called: \(#function)")
        try? dataStore.addTracker(tracker, to: "Важное")
    }
    
    func deleteRecord(at indexPath: IndexPath) throws {
        logger.info("called: \(#function)")
        let record = fetchedResultsController.object(at: indexPath)
        try? dataStore.delete(record)
    }
    
    // Установить текущую дату и обновить фильтрацию
    func setCurrentDate(_ date: Date) {
        logger.info("called: \(#function)")
        self.currentDate = date
        
        updatePredicate()
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension DataProvider: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        logger.info("called: \(#function) \(#line)")
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        logger.info("called: \(#function) \(#line)")
        delegate?.didUpdate(NotepadStoreUpdate(
                insertedIndexes: insertedIndexes!,
                deletedIndexes: deletedIndexes!
            )
        )
        insertedIndexes = nil
        deletedIndexes = nil
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        logger.info("called: \(#function) \(#line)")

        switch type {
        case .delete:
            if let indexPath = indexPath {
                deletedIndexes?.insert(indexPath.item)
            }
        case .insert:
            if let indexPath = newIndexPath {
                insertedIndexes?.insert(indexPath.item)
            }
        default:
            break
        }
    }
}
