//
//  TrackerDataStore.swift
//  Tracker
//
//  Created by Дмитрий Чалов on 12.12.2025.
//

import CoreData

protocol TrackerDataStore {
    var managedObjectContext: NSManagedObjectContext? { get }
    func addTracker(_ tracker: Tracker, to categoryTitle: String) throws
    func delete(_ tracker: NSManagedObject) throws
}
