//
//  File.swift
//  Tracker
//
//  Created by Дмитрий Чалов on 12.12.2025.
//


import CoreData

extension NSPersistentContainer {
    static func load(name: String, model: NSManagedObjectModel, url: URL) throws -> NSPersistentContainer {
        let description = NSPersistentStoreDescription(url: url)
        let container = NSPersistentContainer(name: name, managedObjectModel: model)
        container.persistentStoreDescriptions = [description]

        var loadError: Swift.Error?
        container.loadPersistentStores { loadError = $1 }
        try loadError.map { throw $0 }

        print("✅ NSPersistentContainer получен")
        return container
    }
}
