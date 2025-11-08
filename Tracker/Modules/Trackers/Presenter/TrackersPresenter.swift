//
//  TrackersPresenter.swift
//  Tracker
//
//  Created by Дмитрий Чалов on 08.11.2025.
//

import UIKit

final class TrackersPresenter: TrackersPresenterProtocol {
    // MARK: - Private properties
    private weak var view: TrackersViewProtocol?
    private let repository: TrackerRepositoryProtocol

    private var categories: [TrackerCategory] = []
    private var completedRecords: [TrackerRecord] = []
    private var selectedDate = Date()

    // MARK: - Lifecycle
    init(view: TrackersViewProtocol, repository: TrackerRepositoryProtocol) {
        self.view = view
        self.repository = repository
    }

    func viewDidLoad() {
        categories = repository.fetchCategories()
        displayTrackers(for: selectedDate)
        print("PRESENTER viewDidLoad called")

    }

    // MARK: - Public methods
    func didSelectDate(_ date: Date) {
        selectedDate = date
        displayTrackers(for: date)
    }

    func didTapAddButton() {
        print("➕ Add button tapped")
    }

    func configureCell(_ cell: TrackerCollectionViewCell, with tracker: Tracker) {
        let isCompleted = completedRecords.contains { $0.id == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
        let completedDays = completedRecords.filter { $0.id == tracker.id }.count
        
        cell.configure(with: tracker, completedDays: completedDays, isCompletedToday: isCompleted)
        cell.onDoneButtonTapped = { [weak self] trackerId in
            self?.toggleTrackerCompletion(for: trackerId)
        }
    }

    // MARK: - Private methods
    private func displayTrackers(for date: Date) {
        let visible = repository.filteredCategories(for: date, from: categories)
        if visible.isEmpty {
            view?.showEmptyState()
        } else {
            view?.updateCategories(visible)
        }
    }

    private func toggleTrackerCompletion(for trackerId: UUID) {
        guard Date() > selectedDate else {
            view?.showFutureDateRestriction()
            return
        }

        if let index = completedRecords.firstIndex(where: { $0.id == trackerId && Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }) {
            completedRecords.remove(at: index)
        } else {
            completedRecords.append(TrackerRecord(id: trackerId, date: selectedDate))
        }
        view?.updateSingleTracker(trackerId, completedRecords: completedRecords)
    }
}
