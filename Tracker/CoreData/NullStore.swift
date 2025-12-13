//
//  NullStore.swift
//  Tracker
//
//  Created by Дмитрий Чалов on 12.12.2025.
//


import CoreData

final class NullStore {}

extension NullStore: TrackerDataStore {
    var managedObjectContext: NSManagedObjectContext? { nil }
    func addTracker(_ tracker: Tracker, to categoryTitle: String) throws {}
    func delete(_ tracker: NSManagedObject) throws {}
}
