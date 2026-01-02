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

    enum StoreError: Error {
        case modelNotFound
        case failedToLoadPersistentContainer(Error)
    }
    
    init() throws {
        logger.info("called: \(#function)")
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
    
    var managedObjectContext: NSManagedObjectContext? {
        logger.info("called: \(#function)")
        return context
    }
    
    private func cleanUpReferencesToPersistentStores() {
        logger.info("called: \(#function)")
        context.performAndWait {
            let coordinator = self.container.persistentStoreCoordinator
            try? coordinator.persistentStores.forEach(coordinator.remove)
        }
    }
    
    deinit {
        print("🎄Убираем ссылку на PersistentStores")
        cleanUpReferencesToPersistentStores()
    }
}
