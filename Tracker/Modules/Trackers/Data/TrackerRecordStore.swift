//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Дмитрий Чалов on 03.12.2025.
//

import CoreData
import UIKit

final class TrackerRecordStore {
    private let context: NSManagedObjectContext

    convenience init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func addNewTrackerRecord(_ trackerRecord: TrackerRecord) throws {
        let trackerRecordCorData = TrackerRecordCoreData(context: context)
        updateExistingTrackerRecord(trackerRecordCorData, with: trackerRecord)
        try context.save()
    }

    func updateExistingTrackerRecord(_ trackerRecordCorData: TrackerRecordCoreData, with trackerRecord: TrackerRecord) {
        trackerRecordCorData.id = trackerRecord.id
        trackerRecordCorData.date = trackerRecord.date
    }

}
