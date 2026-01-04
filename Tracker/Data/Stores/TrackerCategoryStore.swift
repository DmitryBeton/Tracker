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
    enum StoreError: Error {
        case categoryNotFound(String)
    }
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func createCategory(withTitle title: String) throws {
        let newCategory = TrackerCategoryCoreData(context: context)
        newCategory.id = UUID()
        newCategory.title = title
        try context.save()
    }
    
    func deleteCategory(withTitle title: String) throws {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", title)
        fetchRequest.fetchLimit = 1
        
        let results = try context.fetch(fetchRequest)
        if let category = results.first {
            context.delete(category)
            try context.save()
        }
         else { throw StoreError.categoryNotFound(title) }
    }
    
    func findCategory(withTitle title: String) throws -> TrackerCategoryCoreData {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", title)
        fetchRequest.fetchLimit = 1
        
        let results = try context.fetch(fetchRequest)
        guard let category = results.first else {
            throw StoreError.categoryNotFound(title)
        }
        return category
    }
    
    func fetchAllCategories() throws -> [TrackerCategoryCoreData] {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        return try context.fetch(fetchRequest)
    }
}
