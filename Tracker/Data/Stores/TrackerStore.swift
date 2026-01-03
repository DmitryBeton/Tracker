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
    private let context: NSManagedObjectContext
    
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
        let managedTracker = TrackerCoreData(context: context)
        managedTracker.id = tracker.id
        managedTracker.name = tracker.name
        managedTracker.color = UIColorMarshalling.hexString(from: tracker.color)
        managedTracker.emoji = tracker.emoji
        managedTracker.schedule = tracker.schedule as NSObject?
        managedTracker.category = category
        
        try context.save()
    }
    
    func deleteTracker(_ tracker: NSManagedObject) throws {
        context.delete(tracker)
        try context.save()
    }
    
    func fetchTrackers(with predicate: NSPredicate? = nil) throws -> [TrackerCoreData] {
        let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        fetchRequest.predicate = predicate
        return try context.fetch(fetchRequest)
    }
    
    func updateFetchedResultsControllerPredicate(_ predicate: NSPredicate?) {
        fetchedResultsController.fetchRequest.predicate = predicate
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("❌ Ошибка обновления предиката: \(error)")
        }
    }
}
