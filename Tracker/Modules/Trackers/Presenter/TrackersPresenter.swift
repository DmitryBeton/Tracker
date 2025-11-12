//
//  TrackersPresenter.swift
//  Tracker
//
//  Created by Дмитрий Чалов on 08.11.2025.
//

import UIKit
import Logging

final class TrackersPresenter {
    // MARK: - Dependencies
    private weak var view: TrackersViewProtocol?
    private let repository: TrackerRepositoryProtocol
    private let logger = Logger(label: "TrackersPresenter")

    // MARK: - State
    private var categories: [TrackerCategory] = []
    private var completedRecords: [TrackerRecord] = []
    private var selectedDate = Date()

    // MARK: - Init
    init(view: TrackersViewProtocol, repository: TrackerRepositoryProtocol) {
        self.view = view
        self.repository = repository
        logger.info("🎯 TrackersPresenter инициализирован")
    }

    // MARK: - Private methods
    private func displayTrackers(for date: Date) {
        logger.debug("🔄 Обновление отображения для даты: \(date)")
        let visible = repository.filteredCategories(for: date, from: categories)

        if visible.isEmpty {
            logger.info("📭 Нет трекеров для отображения. Показ пустого состояния")
            view?.updateCategories([])
            view?.showEmptyState()
        } else {
            logger.debug("✅ Отображение \(visible.count) категорий с трекерами")
            view?.updateCategories(visible)
            view?.hideEmptyState()
        }
    }

    private func toggleTrackerCompletion(for trackerId: UUID) {
        logger.info("🔘 Переключение выполнения трекера \(trackerId) на дату \(selectedDate)")

        guard Date() > selectedDate else {
            logger.warning("⚠️ Попытка отметить трекер на будущую дату: \(selectedDate)")
            view?.showFutureDateRestriction()
            return
        }

        if let index = completedRecords.firstIndex(where: { $0.id == trackerId && Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }) {
            completedRecords.remove(at: index)
            logger.debug("❌ Снято выполнение с трекера \(trackerId)")
        } else {
            completedRecords.append(TrackerRecord(id: trackerId, date: selectedDate))
            logger.debug("✅ Отмечено выполнение трекера \(trackerId)")
        }
        
        let totalCompletions = completedRecords.filter { $0.id == trackerId }.count
        logger.trace("📊 Трекер \(trackerId) выполнен всего: \(totalCompletions) раз")
        view?.updateSingleTracker(trackerId, completedRecords: completedRecords)
    }
}

// MARK: - TrackersPresenterProtocol
extension TrackersPresenter: TrackersPresenterProtocol {
    func viewDidLoad() {
        logger.info("🔄 Загрузка данных при запуске")
        categories = repository.fetchCategories()
        logger.debug("📊 Загружено категорий: \(categories.count), трекеров: \(categories.flatMap { $0.trackers }.count)")
        displayTrackers(for: selectedDate)
    }

    func didSelectDate(_ date: Date) {
        selectedDate = date
        logger.info("📅 Пользователь выбрал дату: \(date)")
        displayTrackers(for: date)
    }

    func didTapAddTracker() {
        logger.info("➕ Пользователь нажал кнопку добавления трекера")
        view?.showCreateTrackerScreen()
    }
    
    func createNewTracker(_ tracker: Tracker) { // TODO: В следующих спринтах добавить параметр category
        logger.info("🆕 Создание нового трекера: '\(tracker.name)'")

        repository.addTracker(tracker, toCategory: "Важные дела")
        
        categories = repository.fetchCategories()
        logger.debug("📊 Категории обновлены.")

        displayTrackers(for: selectedDate)
    }

    func configureCell(_ cell: TrackerCollectionViewCell, with tracker: Tracker) {
        let isCompleted = completedRecords.contains { $0.id == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
        let completedDays = completedRecords.filter { $0.id == tracker.id }.count
        
        cell.configure(with: tracker, completedDays: completedDays, isCompletedToday: isCompleted)
        cell.onDoneButtonTapped = { [weak self] trackerId in
            self?.toggleTrackerCompletion(for: trackerId)
        }
    }
}

