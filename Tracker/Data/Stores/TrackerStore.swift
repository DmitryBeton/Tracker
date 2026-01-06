//
//  TrackerStore.swift
//  Tracker
//
//  Created by Дмитрий Чалов on 12.12.2025.
//

import UIKit
import CoreData
import Logging

enum StoreError: Error {
    case trackerNotFound(UUID)
    case fetchFailed(Error)
}

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
    
    func getSchedule(for trackerId: UUID) throws -> [WeekDay] {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", trackerId as CVarArg)
        fetchRequest.fetchLimit = 1
        
        do {
            guard let tracker = try context.fetch(fetchRequest).first else {
                throw StoreError.trackerNotFound(trackerId)
            }
            
            // Если используется DaysValueTransformer
            // Он должен автоматически конвертировать Data в [WeekDay]
            if let schedule = tracker.schedule as? [WeekDay] {
                return schedule
            }
            
            // Попробуем вручную, если автоматическая конвертация не работает
            if let scheduleData = tracker.schedule as? Data {
                let decoder = JSONDecoder()
                return try decoder.decode([WeekDay].self, from: scheduleData)
            }
            
            return []
            
        } catch {
            throw StoreError.fetchFailed(error)
        }
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
    
    func deleteTracker(_ tracker: UUID) throws {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", tracker as CVarArg)
        fetchRequest.fetchLimit = 1
        
        let results = try context.fetch(fetchRequest)
        if let tracker = results.first {
            context.delete(tracker)
            try context.save()
        }
         else { throw StoreError.trackerNotFound(tracker) }
    }
    
    func editTracker(_ tracker: Tracker) throws {
        
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
