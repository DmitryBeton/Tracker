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
    private let logger = Logger(label: "TrackerCategoryStore")
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func findOrCreateCategory(withTitle title: String) throws -> TrackerCategoryCoreData {
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
        
        try context.save()
        return newCategory
    }
    
    func fetchAllCategories() throws -> [TrackerCategoryCoreData] {
        logger.info("called: \(#function)")
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        return try context.fetch(fetchRequest)
    }
    
    func deleteCategory(_ category: TrackerCategoryCoreData) throws {
        logger.info("called: \(#function)")
        context.delete(category)
        try context.save()
    }
}
