//
//  CreateTrackerPresenter.swift
//  Tracker
//
//  Created by Дмитрий Чалов on 09.11.2025.
//

import UIKit
import Logging

final class CreateTrackerPresenter {
    // MARK: - Dependencies
    private let logger = Logger(label: "CreateTrackerPresenter")
    private weak var view: CreateTrackerViewProtocol?
    private let trackerRepository: TrackerRepositoryProtocol
    private let onCreateTracker: ((Tracker) -> Void)?

    
    // MARK: - Lifecycle
    init(view: CreateTrackerViewProtocol, repository: TrackerRepositoryProtocol, onCreateTracker: ((Tracker) -> Void)? = nil) {
        self.view = view
        self.trackerRepository = repository
        self.onCreateTracker = onCreateTracker
        logger.info("🎯 CreateTrackerPresenter инициализирован")
    }
}

// MARK: - CreateTrackerPresenterProtocol
extension CreateTrackerPresenter: CreateTrackerPresenterProtocol {
    func didTapCreate(name: String, schedule: TrackerSchedule?) {
        logger.info("🎯 Начало создания трекера. Имя: '\(name)', расписание: \(schedule != nil ? "установлено" : "не установлено")") // Проверка на nil, нужра для задания со зведочкой

        guard !name.isEmpty, let schedule = schedule else { return }
        
        let colors: [UIColor] = [.ypBlue, .ypRed]
        
        let newTracker = Tracker(
            name: name,
            color: colors.randomElement()!, // Force unwrap здесь это временное решение, уберу в следующих спринтах, когда будет полноценное меню выбора цвета
            emoji: "emoji",
            schedule: schedule
        )
        logger.info("✅ Трекер создан: '\(name)' с расписанием: \(schedule.displayText)")
        
        onCreateTracker?(newTracker)
        logger.debug("🔄 Трекер передан через колбэк")

        view?.closeCreateTracker()
    }
}
