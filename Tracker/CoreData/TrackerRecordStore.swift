//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Дмитрий Чалов on 12.12.2025.
//

import CoreData
import Logging

// MARK: - TrackerRecordStore
final class TrackerRecordStore {
    private let logger = Logger(label: "TrackerRecordStore")
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func addRecord(trackerId: UUID, date: Date) throws {
        logger.info("called: \(#function)")
        
        let record = TrackerRecordCoreData(context: context)
        record.id = trackerId
        record.date = Calendar.current.startOfDay(for: date)
        try context.save()
    }
    
    func deleteRecord(trackerId: UUID, date: Date) throws {
        logger.info("called: \(#function)")
        
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
    
    func fetchAllRecords() throws -> [TrackerRecord] {
        logger.info("called: \(#function)")
        
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        let result = try context.fetch(request)
        return result.compactMap {
            guard let id = $0.id, let date = $0.date else { return nil }
            return TrackerRecord(id: id, date: date)
        }
    }
    
    func fetchRecords(for trackerId: UUID) throws -> [TrackerRecord] {
        logger.info("called: \(#function)")
        
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", trackerId as CVarArg)
        
        let result = try context.fetch(request)
        return result.compactMap {
            guard let id = $0.id, let date = $0.date else { return nil }
            return TrackerRecord(id: id, date: date)
        }
    }
}
