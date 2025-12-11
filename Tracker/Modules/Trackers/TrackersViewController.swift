//
//  TrackerListViewController.swift
//  Tracker
//
//  Created by Дмитрий Чалов on 31.10.2025.
//

import UIKit
import Logging

final class TrackersViewController: UIViewController {
    // MARK: - Private properties
    private let logger = Logger(label: "TrackersViewController")
    private let repository: TrackerRepositoryProtocol = MockTrackersRepository()
    
    private var categories: [TrackerCategory] = []
    private var completedRecords: [TrackerRecord] = []
    private var selectedDate = Date()
    private var visibleCategories: [TrackerCategory] = []
    
    // MARK: - UI Elements
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .ypWhite
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    private let emptyStateView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.isHidden = true
        return stackView
    }()
    
    private let dizzyImage: UIImageView = {
        let image = UIImageView(image: UIImage(resource: .dizzy))
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let datePicker = UIDatePicker()
    private let searchController = UISearchController(searchResultsController: nil)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadTrackers()
        logger.info("✅ Главный экран трекеров готов к работе")
    }
    
    // MARK: - Private methods
    private func loadTrackers() {
        logger.info("🔄 Загрузка данных при запуске")
        categories = repository.fetchCategories()
        logger.debug("📊 Загружено категорий: \(categories.count), трекеров: \(categories.flatMap { $0.trackers }.count)")
        displayTrackers(for: selectedDate)
    }
    
    private func displayTrackers(for date: Date) {
        logger.debug("🔄 Обновление отображения для даты: \(date)")
        visibleCategories = repository.filteredCategories(for: date, from: categories)
        
        if visibleCategories.isEmpty {
            logger.info("📭 Нет трекеров для отображения. Показ пустого состояния")
            collectionView.reloadData()
            showEmptyState()
        } else {
            logger.debug("✅ Отображение \(visibleCategories.count) категорий с трекерами")
            collectionView.reloadData()
            hideEmptyState()
        }
    }
    
    private func toggleTrackerCompletion(for trackerId: UUID) {
        logger.info("🔘 Переключение выполнения трекера \(trackerId) на дату \(selectedDate)")
        
        guard Date() > selectedDate else {
            logger.warning("⚠️ Попытка отметить трекер на будущую дату: \(selectedDate)")
            showFutureDateRestriction()
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
        
        // Находим и обновляем конкретную ячейку
        for (sectionIndex, category) in visibleCategories.enumerated() {
            if let rowIndex = category.trackers.firstIndex(where: { $0.id == trackerId }) {
                let indexPath = IndexPath(item: rowIndex, section: sectionIndex)
                collectionView.performBatchUpdates({
                    collectionView.reloadItems(at: [indexPath])
                }, completion: nil)
                break
            }
        }
    }
    
    private func showFutureDateRestriction() {
        let alert = UIAlertController(
            title: "Недоступно",
            message: "Нельзя отмечать трекеры на будущие даты.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "ОК", style: .default))
        present(alert, animated: true)
    }
    
    private func showEmptyState() {
        emptyStateView.isHidden = false
    }
    
    private func hideEmptyState() {
        emptyStateView.isHidden = true
    }
    
    private func createNewTracker(_ tracker: Tracker) {
        logger.info("🆕 Создание нового трекера: '\(tracker.name)'")
        
        repository.addTracker(tracker, toCategory: "Важное")
        
        categories = repository.fetchCategories()
        logger.debug("📊 Категории обновлены.")
        
        displayTrackers(for: selectedDate)
    }
    
    private func configureCell(_ cell: TrackerCollectionViewCell, with tracker: Tracker) {
        let isCompleted = completedRecords.contains { $0.id == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
        let completedDays = completedRecords.filter { $0.id == tracker.id }.count
        
        cell.configure(with: tracker, completedDays: completedDays, isCompletedToday: isCompleted)
        cell.onDoneButtonTapped = { [weak self] trackerId in
            self?.toggleTrackerCompletion(for: trackerId)
        }
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .ypWhite
        setupNavigation()
        
        view.addSubview(collectionView)
        view.addSubview(emptyStateView)
        emptyStateView.addSubview(dizzyImage)
        emptyStateView.addSubview(label)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(
            TrackerCollectionViewCell.self,
            forCellWithReuseIdentifier: "Cell"
        )
        collectionView.register(
            TrackerHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TrackerHeaderView.reuseIdentifier
        )
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск"
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: view.rightAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            dizzyImage.topAnchor.constraint(equalTo: emptyStateView.topAnchor),
            dizzyImage.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            
            label.topAnchor.constraint(equalTo: dizzyImage.bottomAnchor, constant: 8),
            label.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
        ])
    }
    
    private func setupNavigation() {
        title = "Трекеры"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .ypWhite
        appearance.shadowColor = .clear
        
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.ypBlack,
            .font: UIFont.systemFont(ofSize: 17, weight: .bold)
        ]
        
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.ypBlack,
            .font: UIFont.systemFont(ofSize: 34, weight: .bold)
        ]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        
        let addImage = UIImage(resource: .addTracker)
        let addButton = UIBarButtonItem(
            image: addImage,
            style: .plain,
            target: self,
            action: #selector(addTapped)
        )
        addButton.tintColor = .ypBlack
        navigationItem.leftBarButtonItem = addButton
        
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    // MARK: - Actions
    @objc private func addTapped() {
        logger.info("➕ Пользователь нажал кнопку добавления трекера")
        showCreateTrackerScreen()
    }
    
    @objc private func dateChanged() {
        selectedDate = datePicker.date
        logger.info("📅 Пользователь выбрал дату: \(selectedDate)")
        displayTrackers(for: selectedDate)
    }
    
    private func showCreateTrackerScreen() {
        let createVC = CreateTrackerViewController()
        createVC.title = "Новая привычка"
        
        // В MVC передаем колбэк напрямую
        createVC.onCreateTracker = { [weak self] newTracker in
            self?.logger.info("🔄 Получен новый трекер из CreateTracker: '\(newTracker.name)'")
            self?.createNewTracker(newTracker)
        }
        
        let navVC = UINavigationController(rootViewController: createVC)
        present(navVC, animated: true)
    }
}

// MARK: - UICollectionViewDataSource & UICollectionViewDelegateFlowLayout
extension TrackersViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    // MARK: - Sections & Items
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        visibleCategories[section].trackers.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "Cell",
            for: indexPath
        ) as? TrackerCollectionViewCell else {
            assertionFailure("Failed to dequeue TrackerCollectionViewCell")
            return UICollectionViewCell()
        }
        
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        configureCell(cell, with: tracker)
        return cell
    }
    
    // MARK: - Layout (Size & Spacing)
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        CGSize(width: 167, height: 148)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        UIEdgeInsets(top: 12, left: 16, bottom: 16, right: 16)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        16
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        9
    }
    
    // MARK: - Section Headers
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: TrackerHeaderView.reuseIdentifier,
            for: indexPath
        ) as! TrackerHeaderView
        
        let category = visibleCategories[indexPath.section]
        header.configure(with: category.title)
        return header
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        CGSize(width: collectionView.frame.width, height: 40)
    }
}

// MARK: - UISearchResultsUpdating
extension TrackersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text, !searchText.isEmpty else {
            displayTrackers(for: selectedDate)
            return
        }
        
        // Фильтрация по поисковому запросу
        let filtered = categories.map { category in
            let filteredTrackers = category.trackers.filter { tracker in
                tracker.name.localizedCaseInsensitiveContains(searchText)
            }
            return TrackerCategory(title: category.title, trackers: filteredTrackers)
        }.filter { !$0.trackers.isEmpty }
        
        visibleCategories = filtered
        
        if visibleCategories.isEmpty {
            showEmptyState()
        } else {
            hideEmptyState()
        }
        
        collectionView.reloadData()
    }
}
