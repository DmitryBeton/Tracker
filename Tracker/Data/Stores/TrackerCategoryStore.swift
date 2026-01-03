//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Дмитрий Чалов on 12.12.2025.
//

import CoreData
import Logging

// MARK: - TrackerCategoryStore
final class TrackerCategoryStore {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func createCategory(withTitle title: String) throws {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", title)
        fetchRequest.fetchLimit = 1
        
        let newCategory = TrackerCategoryCoreData(context: context)
        newCategory.id = UUID()
        newCategory.title = title
        try context.save()
    }
    
    func findCategory(withTitle title: String) throws -> TrackerCategoryCoreData {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", title)
        fetchRequest.fetchLimit = 1
        
        let results = try context.fetch(fetchRequest)
        return results.first!
    }
    
    func fetchAllCategories() throws -> [TrackerCategoryCoreData] {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        return try context.fetch(fetchRequest)
    }
}
