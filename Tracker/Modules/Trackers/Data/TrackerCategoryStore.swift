//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Дмитрий Чалов on 03.12.2025.
//

import CoreData
import UIKit

final class TrackerCategoryStore {
    private let context: NSManagedObjectContext

    convenience init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func addNewTrackerRecord(_ trackerCategory: TrackerCategory) throws {
        let trackerCategoryCorData = TrackerCategoryCoreData(context: context)
        updateExistingTrackerCategory(trackerCategoryCorData, with: trackerCategory)
        try context.save()
    }

    func updateExistingTrackerCategory(_ trackerCategoryCorData: TrackerCategoryCoreData, with trackerCategory: TrackerCategory) {
        trackerCategoryCorData.title = trackerCategory.title
        
    }

}
