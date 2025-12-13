//
//  NotepadStoreUpdate.swift
//  Tracker
//
//  Created by Дмитрий Чалов on 12.12.2025.
//


import UIKit
import CoreData

struct NotepadStoreUpdate {
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
}

protocol DataProviderDelegate: AnyObject {
    func didUpdate(_ update: NotepadStoreUpdate)
}

protocol DataProviderProtocol {
    var numberOfCategories: Int { get }
    func numberOfTrackersInCategory(_ section: Int) -> Int
    func tracker(at: IndexPath) -> TrackerCoreData?
    func categoryTitle(at index: Int) -> String
    func addTracker(_ tracker: Tracker, to: String) throws
    func deleteRecord(at indexPath: IndexPath) throws
    
    // Фильтрация по дате
    func setCurrentDate(_ date: Date) // Установить текущую дату для фильтрации
    func fetchFilteredCategories() -> [TrackerCategory] // Получить отфильтрованные категории
}

// MARK: - DataProvider
final class DataProvider: NSObject {

    enum DataProviderError: Error {
        case failedToInitializeContext
    }
    
    weak var delegate: DataProviderDelegate?
    
    private let context: NSManagedObjectContext
    private let dataStore: TrackerDataStore
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    private var currentDate: Date = Date() // Текущая дата для фильтрации
    private let uiColorMarshalling = UIColorMarshalling.shared
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        
        // Базовый предикат
        let predicate = getPredicateForCurrentDate()
        fetchRequest.predicate = predicate
        
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "category.title", ascending: true),
            NSSortDescriptor(key: "name", ascending: true)
        ]
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: "category.title",
            cacheName: nil
        )
        
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        
        return fetchedResultsController
    }()
    
    init(_ dataStore: TrackerDataStore, delegate: DataProviderDelegate) throws {
        guard let context = dataStore.managedObjectContext else {
            throw DataProviderError.failedToInitializeContext
        }
        self.delegate = delegate
        self.context = context
        self.dataStore = dataStore
    }
    
    // Метод для получения предиката фильтрации по текущей дате
    private func getPredicateForCurrentDate() -> NSPredicate? {
        // Получаем день недели из currentDate
        guard let currentWeekDay = WeekDay.fromDate(currentDate) else {
            print("❌ Не удалось определить день недели для даты: \(currentDate)")
            return NSPredicate(value: false) // Ничего не показывать
        }

        // Создаем предикат:
        // 1. Либо schedule = nil (трекеры без расписания показываем всегда)
        // 2. Либо schedule содержит currentWeekDay
        
        // Проблема: schedule хранится как Data, нельзя фильтровать через contains
        // Поэтому фильтруем вручную в shouldDisplayTracker
        
        
         return createComplexPredicate(for: currentWeekDay)
    }
    
    private func createComplexPredicate(for weekDay: WeekDay) -> NSPredicate? {
        // Сложный предикат для фильтрации в CoreData
        // Работает только если schedule хранится как String, а не Data
        
        // Конвертируем WeekDay в строку для поиска
        let dayString = "\(weekDay.rawValue)"
        
        // Ищем JSON строку, содержащую этот номер дня
        // Пример: schedule содержит "[1,3,5]" - ищем "1" или ",1," или "[1" или "1]"
        return NSPredicate(format: "schedule CONTAINS %@", dayString)
    }
    
    // Обновить предикат при смене даты
    private func updatePredicate() {
        let predicate = getPredicateForCurrentDate()
        fetchedResultsController.fetchRequest.predicate = predicate
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("❌ Ошибка обновления предиката: \(error)")
        }
    }
}

// MARK: - DataProviderProtocol
extension DataProvider: DataProviderProtocol {
    var numberOfCategories: Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func numberOfTrackersInCategory(_ section: Int) -> Int {
        // ВАЖНО: Проверяем существование секции
        guard let sections = fetchedResultsController.sections,
              section < sections.count else {
            print("⚠️ Ошибка: запрошенной секции \(section) не существует")
            return 0
        }
        
        let numberOfObjects = sections[section].numberOfObjects
        return numberOfObjects
    }
    
    func tracker(at indexPath: IndexPath) -> TrackerCoreData? {
        // ВАЖНО: Проверяем валидность indexPath
        guard let sections = fetchedResultsController.sections,
              indexPath.section < sections.count,
              indexPath.row < sections[indexPath.section].numberOfObjects else {
            print("❌ Ошибка: indexPath \(indexPath) вне границ")
            return nil
        }
        return fetchedResultsController.object(at: indexPath)
    }
    
    func categoryTitle(at index: Int) -> String {
        guard let sections = fetchedResultsController.sections,
              index < sections.count else {
            print("⚠️ Секция \(index) не существует")
            return "Категория"
        }
        let sectionInfo = sections[index]
        // 2. Получаем первый трекер в секции
        guard let objects = sectionInfo.objects as? [TrackerCoreData],
              let firstObject = objects.first else {
            print("⚠️ Секция \(index) пустая")
            return "Категория \(index + 1)"
        }
        // 3. Получаем связанную категорию
        guard let categoryEntity = firstObject.category,
              let title = categoryEntity.title, !title.isEmpty
        else {
            print("⚠️ Ошибка получения трекера из секции \(index)")
            return "Без категории"
        }
        return title
    }
    
    func addTracker(_ tracker: Tracker, to: String) throws {
        try? dataStore.addTracker(tracker, to: "Важное")
    }
    
    func deleteRecord(at indexPath: IndexPath) throws {
        let record = fetchedResultsController.object(at: indexPath)
        try? dataStore.delete(record)
    }
    
    // Установить текущую дату и обновить фильтрацию
    func setCurrentDate(_ date: Date) {
        
        // Сохраняем новую дату
        self.currentDate = date
        
        // Обновляем фильтрацию
        updatePredicate()
        
        // Уведомляем делегата об обновлении данных
        // (данные обновятся через NSFetchedResultsControllerDelegate)
    }
    
    // Получить отфильтрованные категории
    func fetchFilteredCategories() -> [TrackerCategory] {
        
        guard let sections = fetchedResultsController.sections else {
            return []
        }
        
        var categories: [TrackerCategory] = []
        
        for sectionInfo in sections {
            // Получаем трекеры из секции
            guard let objects = sectionInfo.objects as? [TrackerCoreData] else {
                continue
            }
            
            // Фильтруем трекеры по текущему дню недели
            let filteredTrackers: [Tracker] = objects.compactMap { coreDataObject in
                // Конвертируем в Tracker
                guard let tracker = convertToTracker(coreDataObject) else {
                    return nil
                }
                
                // Проверяем, должен ли трекер отображаться в текущий день
                return shouldDisplayTracker(tracker, on: currentDate) ? tracker : nil
            }
            
            // Если есть отфильтрованные трекеры - создаем категорию
            if !filteredTrackers.isEmpty {
                let categoryTitle = sectionInfo.name
                let category = TrackerCategory(title: categoryTitle, trackers: filteredTrackers)
                categories.append(category)
            }
        }
        
        return categories
    }
    
    // Проверка, должен ли трекер отображаться на указанную дату
    private func shouldDisplayTracker(_ tracker: Tracker, on date: Date) -> Bool {
        // Получаем день недели из даты
        guard let dateWeekDay = WeekDay.fromDate(date) else {
            return false
        }
        
        // Если у трекера нет расписания - показываем всегда (для нерегулярных)
        guard let schedule = tracker.schedule else {
            return true
        }
        
        // Проверяем, содержит ли расписание текущий день
        return schedule.contains(dateWeekDay)
    }
    
    // Конвертация TrackerCoreData в Tracker
    private func convertToTracker(_ coreDataObject: TrackerCoreData) -> Tracker? {
        guard let id = coreDataObject.id,
              let name = coreDataObject.name,
              let emoji = coreDataObject.emoji,
              let color = coreDataObject.color else {
            print("❌ Не удалось конвертировать TrackerCoreData")
            return nil
        }
        
        // Получаем расписание и конвертируем в [WeekDay]?
        var schedule: [WeekDay]?
        if let scheduleData = coreDataObject.schedule as? Data {
            do {
                let daysArray = try JSONDecoder().decode([WeekDay].self, from: scheduleData)
                schedule = daysArray
                print("✅ Расписание декодировано: \(daysArray.count) дней")
            } catch {
                print("❌ Ошибка декодирования расписания: \(error)")
            }
        } else {
            print("ℹ️ Расписание отсутствует (nil)")
        }
        
        return Tracker(
            id: id,
            name: name,
            color: uiColorMarshalling.color(from: color),
            emoji: emoji,
            schedule: schedule
        )
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension DataProvider: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdate(NotepadStoreUpdate(
                insertedIndexes: insertedIndexes!,
                deletedIndexes: deletedIndexes!
            )
        )
        insertedIndexes = nil
        deletedIndexes = nil
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .delete:
            if let indexPath = indexPath {
                deletedIndexes?.insert(indexPath.item)
            }
        case .insert:
            if let indexPath = newIndexPath {
                insertedIndexes?.insert(indexPath.item)
            }
        default:
            break
        }
    }
}

