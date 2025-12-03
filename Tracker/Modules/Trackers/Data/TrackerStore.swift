//
//  TrackerStore.swift
//  Tracker
//
//  Created by Дмитрий Чалов on 03.12.2025.
//

import UIKit
import CoreData

final class TrackerStore {
    private let context: NSManagedObjectContext

    convenience init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func addNewTracker(_ tracker: Tracker) throws {
        let trackerCorData = TrackerCoreData(context: context)
        updateExistingTracker(trackerCorData, with: tracker)
        try context.save()
    }

    func updateExistingTracker(_ trackerCorData: TrackerCoreData, with tracker: Tracker) {
        trackerCorData.id = tracker.id
        trackerCorData.name = tracker.name
        trackerCorData.color = tracker.color
        trackerCorData.emoji = tracker.emoji
        // TODO: - Сделать Transformable
        //        trackerCorData.schedule = tracker.schedule
    }

}
