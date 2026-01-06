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
        case trackerNotFound(UUID)
        case categoryNotFound(String)
        case fetchFailed(Error)
        
        var localizedDescription: String {
            switch self {
            case .trackerNotFound(let id):
                return "Tracker with ID \(id) not found"
            case .categoryNotFound(let title):
                return "Category \(title) not found for tracker"
            case .fetchFailed(let error):
                return "Fetch failed: \(error.localizedDescription)"
            }
        }
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
    
    func editCategory(withTitle title: String, newTitle: String) throws {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", title)
        fetchRequest.fetchLimit = 1
        
        let results = try context.fetch(fetchRequest)
        if let category = results.first {
            category.title = newTitle
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
    
    func getCategoryTitle(for trackerId: UUID) throws -> String {
        let trackerFetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        trackerFetchRequest.predicate = NSPredicate(format: "id == %@", trackerId as CVarArg)
        trackerFetchRequest.fetchLimit = 1
        
        trackerFetchRequest.relationshipKeyPathsForPrefetching = ["category"]
        
        do {
            guard let tracker = try context.fetch(trackerFetchRequest).first else {
                throw StoreError.trackerNotFound(trackerId)
            }
            
            if let category = tracker.value(forKey: "category") as? TrackerCategoryCoreData,
               let title = category.title {
                return title
            }
            
            throw StoreError.categoryNotFound("error")
        } catch {
            throw StoreError.fetchFailed(error)
        }
    }
}
