//
//  DataStore.swift
//  Tracker
//
//  Created by Дмитрий Чалов on 12.12.2025.
//


import CoreData
import Logging

// MARK: - DataStore
final class DataStore {
    private let logger = Logger(label: "DataStore")

    private let modelName = "Tracker"
    private let storeURL = NSPersistentContainer
                                .defaultDirectoryURL()
                                .appendingPathComponent("data-store.sqlite")
    
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    private let uiColorMarshalling = UIColorMarshalling.shared

    enum StoreError: Error {
        case modelNotFound
        case failedToLoadPersistentContainer(Error)
    }
    
    init() throws {
        logger.info("called: \(#function) \(#line)")
        guard let modelUrl = Bundle(for: DataStore.self).url(forResource: modelName, withExtension: "momd"),
              let model = NSManagedObjectModel(contentsOf: modelUrl) else {
            throw StoreError.modelNotFound
        }
        
        do {
            container = try NSPersistentContainer.load(name: modelName, model: model, url: storeURL)
            context = container.newBackgroundContext()
        } catch {
            throw StoreError.failedToLoadPersistentContainer(error)
        }

    }
    
    private func performSync<R>(_ action: (NSManagedObjectContext) -> Result<R, Error>) throws -> R {
        let context = self.context
        var result: Result<R, Error>!
        context.performAndWait { result = action(context) }
        return try result.get()
    }
    
    private func cleanUpReferencesToPersistentStores() {
        logger.info("called: \(#function) \(#line)")
        context.performAndWait {
            let coordinator = self.container.persistentStoreCoordinator
            try? coordinator.persistentStores.forEach(coordinator.remove)
        }
    }
    
    deinit {
        print("🎄Убираем ссылку на PersistentStores")
        cleanUpReferencesToPersistentStores()
    }
    
    private func findOrCreateCategory(withTitle title: String, in context: NSManagedObjectContext) -> TrackerCategoryCoreData {
        logger.info("called: \(#function)")

        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", title)
        fetchRequest.fetchLimit = 1
        
        do {
            let results = try context.fetch(fetchRequest)
            if let existingCategory = results.first {
                print("✅ Найдена существующая категория '\(title)'")
                return existingCategory
            }
        } catch {
            print("⚠️ Ошибка при поиске категории: \(error)")
        }
        
        let newCategory = TrackerCategoryCoreData(context: context)
        newCategory.id = UUID()
        newCategory.title = title
        print("🆕 Создана новая категория '\(title)'")
        
        return newCategory
    }

}

// MARK: - NotepadDataStore
extension DataStore: TrackerDataStore {
    var managedObjectContext: NSManagedObjectContext? {
        logger.info("called: \(#function)")
        return context
    }
    
    func addTracker(_ tracker: Tracker, to categoryTitle: String) throws {
        logger.info("called: \(#function)")
        try performSync { context in
            Result {
                // 1. Находим или создаем категорию
                let category = findOrCreateCategory(withTitle: categoryTitle, in: context)
                
                // 2. Создаем трекер
                let managedRecord = TrackerCoreData(context: context)
                managedRecord.id = tracker.id
                managedRecord.name = tracker.name
                managedRecord.color = uiColorMarshalling.hexString(from: tracker.color)
                managedRecord.emoji = tracker.emoji
                managedRecord.schedule = tracker.schedule as NSObject?
                managedRecord.category = category
                
                // 4. Сохраняем
                try context.save()
                
                print("✅ Трекер '\(tracker.name)' добавлен в категорию '\(categoryTitle)'")
            }
        }
    }
    
    func delete(_ tracker: NSManagedObject) throws {
        logger.info("called: \(#function)")
        try performSync { context in
            Result {
                context.delete(tracker)
                try context.save()
            }
        }
    }
    
    func addRecord(trackerId: UUID, date: Date) throws {
        logger.info("called: \(#function) \(#line)")
        try performSync { context in
            Result {
                let record = TrackerRecordCoreData(context: context)
                record.id = trackerId
                record.date = Calendar.current.startOfDay(for: date)
                try context.save()
            }
        }
    }

    func deleteRecord(trackerId: UUID, date: Date) throws {
        logger.info("called: \(#function) \(#line)")
        try performSync { context in
            Result {
                let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
                request.predicate = NSPredicate(
                    format: "id == %@ AND date == %@",
                    trackerId as CVarArg,
                    Calendar.current.startOfDay(for: date) as CVarArg
                )
                let records = try context.fetch(request)
                records.forEach { context.delete($0) }
                try context.save()
            }
        }
    }

    func fetchRecords() throws -> [TrackerRecord] {
        logger.info("called: \(#function) \(#line)")
        return try performSync { context in
            Result {
                let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
                let result = try context.fetch(request)
                return result.compactMap {
                    guard let id = $0.id, let date = $0.date else { return nil }
                    return TrackerRecord(id: id, date: date)
                }
            }
        }
    }

}
