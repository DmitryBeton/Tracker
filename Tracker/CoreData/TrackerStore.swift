//
//  TrackerStore.swift
//  Tracker
//
//  Created by Дмитрий Чалов on 12.12.2025.
//

import UIKit
import CoreData
import Logging

// MARK: - TrackerStore
final class TrackerStore: NSObject {
    private let logger = Logger(label: "TrackerStore")
    private let context: NSManagedObjectContext
    private let uiColorMarshalling = UIColorMarshalling.shared
    
    lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
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
        
        try? fetchedResultsController.performFetch()
        
        return fetchedResultsController
    }()
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
    }
    
    func addTracker(_ tracker: Tracker, to category: TrackerCategoryCoreData) throws {
        logger.info("called: \(#function)")
        
        let managedTracker = TrackerCoreData(context: context)
        managedTracker.id = tracker.id
        managedTracker.name = tracker.name
        managedTracker.color = uiColorMarshalling.hexString(from: tracker.color)
        managedTracker.emoji = tracker.emoji
        managedTracker.schedule = tracker.schedule as NSObject?
        managedTracker.category = category
        
        try context.save()
        print("✅ Трекер '\(tracker.name)' добавлен в категорию '\(category.title ?? "")'")
    }
    
    func deleteTracker(_ tracker: NSManagedObject) throws {
        logger.info("called: \(#function)")
        context.delete(tracker)
        try context.save()
    }
    
    func fetchTrackers(with predicate: NSPredicate? = nil) throws -> [TrackerCoreData] {
        logger.info("called: \(#function)")
        let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        fetchRequest.predicate = predicate
        return try context.fetch(fetchRequest)
    }
    
    func updateFetchedResultsControllerPredicate(_ predicate: NSPredicate?) {
        logger.info("called: \(#function)")
        fetchedResultsController.fetchRequest.predicate = predicate
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("❌ Ошибка обновления предиката: \(error)")
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        logger.info("called: \(#function)")
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        logger.info("called: \(#function)")
    }
}
