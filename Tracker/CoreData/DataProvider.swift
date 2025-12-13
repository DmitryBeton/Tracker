//
//  NotepadStoreUpdate.swift
//  Tracker
//
//  Created by Дмитрий Чалов on 12.12.2025.
//


import UIKit
import CoreData

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
    func categoryTitle(at index: Int) -> String // ← Добавьте эту функцию
    func addTracker(_ tracker: Tracker, to: String) throws
    func deleteRecord(at indexPath: IndexPath) throws
}

// MARK: - DataProvider
final class DataProvider: NSObject {

    enum DataProviderError: Error {
        case failedToInitializeContext
    }
    
    weak var delegate: DataProviderDelegate?
    
    private let context: NSManagedObjectContext
    private let dataStore: TrackerDataStore
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {

        let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: false)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: context,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        return fetchedResultsController
    }()
    
    init(_ dataStore: TrackerDataStore, delegate: DataProviderDelegate) throws {
        guard let context = dataStore.managedObjectContext else {
            throw DataProviderError.failedToInitializeContext
        }
        self.delegate = delegate
        self.context = context
        self.dataStore = dataStore
    }
}

// MARK: - DataProviderProtocol
extension DataProvider: DataProviderProtocol {
    var numberOfCategories: Int {
        print("provider numberOfSections \(fetchedResultsController.sections?.count ?? 0)")
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func numberOfTrackersInCategory(_ section: Int) -> Int {
        // ВАЖНО: Проверяем существование секции
        guard let sections = fetchedResultsController.sections,
              section < sections.count else {
            print("⚠️ Ошибка: запрошенной секции \(section) не существует")
            return 0
        }
        
        let numberOfObjects = sections[section].numberOfObjects
        print("provider numberOfRowsInSection \(section): \(numberOfObjects)")
        return numberOfObjects
    }
    
    func tracker(at indexPath: IndexPath) -> TrackerCoreData? {
        print("provider tracker at \(indexPath)")
        
        // ВАЖНО: Проверяем валидность indexPath
        guard let sections = fetchedResultsController.sections,
              indexPath.section < sections.count,
              indexPath.row < sections[indexPath.section].numberOfObjects else {
            print("❌ Ошибка: indexPath \(indexPath) вне границ")
            return nil
        }
        print("✅ Успех: indexPath \(indexPath) в границах")

        return fetchedResultsController.object(at: indexPath)
    }
    
    func categoryTitle(at index: Int) -> String {
        print("📁 categoryTitle at index \(index)")
        // 1. Проверяем существование секции
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
        print("✅ Название категории для секции \(index): '\(title)'")
        return title
    }
    
    func addTracker(_ tracker: Tracker, to: String) throws {
        print("Provider addRecord")
        try? dataStore.addTracker(tracker, to: "Важное")
    }
    
    func deleteRecord(at indexPath: IndexPath) throws {
        print("Provider deleteRecord at index \(indexPath)")
        let record = fetchedResultsController.object(at: indexPath)
        try? dataStore.delete(record)
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension DataProvider: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
        print("provider FetchResult ControllerWillChangeContent \(insertedIndexes)")
        
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdate(NotepadStoreUpdate(
                insertedIndexes: insertedIndexes!,
                deletedIndexes: deletedIndexes!
            )
        )
        insertedIndexes = nil
        deletedIndexes = nil
        print("provider FetchResult controllerDidChangeContent \(insertedIndexes)")

    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
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
        print("provider FetchResult controller \(insertedIndexes)")

    }
}
