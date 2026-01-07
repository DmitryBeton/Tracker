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
    
    private var viewModel: TrackersViewModelProtocol
    private let analyticsService = AnalyticsService()
    
    // MARK: - UI Elements
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .ypWhite
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
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
        let text = NSLocalizedString("what_we_will_be_tracking", comment: "")
        label.text = text
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var filterButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(NSLocalizedString("title_filters", comment: ""), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .ypBlue
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(filterTapped), for: .touchUpInside)
        return button
    }()
    
    private let datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .compact
        datePicker.layer.masksToBounds = true
        datePicker.layer.cornerRadius = 8
        datePicker.datePickerMode = .date
        return datePicker
    }()
    
    private let searchController = UISearchController()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        logger.info("called: \(#function) \(#line)")
        
        setupUI()
        bindViewModel()
        viewModel.reloadTrackers(for: viewModel.selectedDate)
        logger.info("✅ Главный экран трекеров готов к работе")
    }
    
    // MARK: - MVVM Binding
    init(viewModel: TrackersViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func bindViewModel() {
        viewModel.onDataChanged = { [weak self] _ in
            self?.collectionView.reloadData()
        }
        viewModel.onEmptyStateChanged = { [weak self] isEmpty in
            isEmpty ? self?.showEmptyState() : self?.hideEmptyState()
        }
    }
    
    // MARK: - Private methods
    private func showFutureDateRestriction() {
        logger.info("called: \(#function)")
        
        let alert = UIAlertController(
            title: NSLocalizedString("unavailable", comment: ""),
            message: NSLocalizedString("future_date_warning", comment: ""),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "ОК", style: .default))
        present(alert, animated: true)
    }
    
    private func showEmptyState() {
        logger.info("called: \(#function)")
        
        guard emptyStateView.isHidden else { return }
        
        if let text = searchController.searchBar.searchTextField.text,
           !text.isEmpty || viewModel.isFilterActive()
        {
            dizzyImage.image = UIImage(resource: .notFound)
            label.text = NSLocalizedString("not_found", comment: "")
        } else {
            dizzyImage.image = UIImage(resource: .dizzy)
            label.text = NSLocalizedString("what_we_will_be_tracking", comment: "")
        }
        
        filterButton.isHidden = true
        emptyStateView.isHidden = false
        emptyStateView.alpha = 0
        emptyStateView.transform = CGAffineTransform(translationX: 0, y: 20)
        
        UIView.animate(
            withDuration: 0.35,
            delay: 0,
            usingSpringWithDamping: 0.85,
            initialSpringVelocity: 0.5,
            options: [.curveEaseOut]
        ) {
            self.emptyStateView.alpha = 1
            self.emptyStateView.transform = .identity
        }
    }
    
    private func hideEmptyState() {
        logger.info("called: \(#function)")
        
        guard !emptyStateView.isHidden else { return }
        filterButton.isHidden = false
        
        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            options: [.curveEaseIn]
        ) {
            self.emptyStateView.alpha = 0
            self.emptyStateView.transform = CGAffineTransform(translationX: 0, y: 10)
        } completion: { _ in
            self.emptyStateView.isHidden = true
        }
    }
    
    private func showCreateTrackerScreen() {
        logger.info("called: \(#function) \(#line)")
        
        let createTrackerModel = CreateTrackerModel()
        let createTrackerViewModel = CreateTrackerViewModel(for: createTrackerModel)
        let createTrackerVC = CreateTrackerViewController()
        createTrackerVC.initialize(viewModel: createTrackerViewModel)
        createTrackerVC.onCreateTracker = { [weak self] tracker, category in
            self?.viewModel.createNewTracker(tracker, to: category)
        }
        let navVC = UINavigationController(rootViewController: createTrackerVC)
        present(navVC, animated: true)
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        logger.info("called: \(#function) \(#line)")
        
        view.backgroundColor = .ypWhite
        setupNavigation()
        
        view.addSubview(collectionView)
        view.addSubview(filterButton)
        view.addSubview(emptyStateView)
        emptyStateView.addSubview(dizzyImage)
        emptyStateView.addSubview(label)
        
        searchController.searchResultsUpdater = self
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
        
        // Add swipe gestures for date switching
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture(_:)))
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture(_:)))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)

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
            
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filterButton.heightAnchor.constraint(equalToConstant: 50),
            filterButton.widthAnchor.constraint(equalToConstant: 114)
        ])
    }
    
    private func setupNavigation() {
        logger.info("called: \(#function) \(#line)")
        
        let text = NSLocalizedString("title_trackers", comment: "")
        title = text
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
        
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        
        searchController.obscuresBackgroundDuringPresentation = false
        
        let searchText = NSLocalizedString("search", comment: "")
        searchController.searchBar.placeholder = searchText
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }

    // MARK: - Swipe Gesture Handling
    @objc private func handleSwipeGesture(_ gesture: UISwipeGestureRecognizer) {
        let current = viewModel.selectedDate
        var newDate: Date?
        if gesture.direction == .left {
            // Next day
            newDate = Calendar.current.date(byAdding: .day, value: 1, to: current)
        } else if gesture.direction == .right {
            // Previous day
            newDate = Calendar.current.date(byAdding: .day, value: -1, to: current)
        }
        guard let date = newDate else { return }
        datePicker.setDate(date, animated: true)
        viewModel.reloadTrackers(for: date)
    }
    
    // MARK: - Actions
    @objc private func addTapped() {
        logger.info("called: \(#function) \(#line)")
        analyticsService.report(event: "click", params: ["screen": "main", "item" : "add_track"])
        showCreateTrackerScreen()
    }
    
    @objc private func dateChanged() {
        logger.info("called: \(#function) \(#line)")
        viewModel.reloadTrackers(for: datePicker.date)
    }
    
    private func editTapped(onTracker: Tracker) {
        analyticsService.report(event: "click", params: ["screen": "main", "item" : "edit"])
        guard let dataProvider = viewModel.getDataProvider() else {
            return
        }
        let editM = EditTrackerModel(dataProvider: dataProvider, trackerEditing: onTracker)
        let editVM = EditTrackerViewModel(for: editM)
        let editVC = EditTrackerViewController()
        editVC.initialize(viewModel: editVM)
    
        editVC.onEditTracker = { [weak self] tracker in
            print("EditView -> editTapped() -> \(tracker)")
            self?.viewModel.editTracker(tracker)
        }
        
        present(UINavigationController(rootViewController: editVC), animated: true)
    }
    
    private func deleteTapped(tracker: Tracker) {
        let alert = UIAlertController(
            title: "",
            message: NSLocalizedString("wanna_delete_tracker", comment: ""),
            preferredStyle: .actionSheet
        )
        alert.addAction(UIAlertAction(title: NSLocalizedString("delete", comment: ""), style: .destructive) { [weak self] _ in self?.viewModel.deleteTracker(tracker.id) })
        alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .default))

        present(alert, animated: true)

    }

    
    @objc private func filterTapped() {
        analyticsService.report(event: "click", params: ["screen": "main", "item" : "filter"])

        guard let dataProvider = viewModel.getDataProvider() else {
            return
        }
        let filterVM = FilterViewModel(dataProvider: dataProvider)
        let filterVC = FilterViewController(viewModel: filterVM)
        filterVC.onFilterChanged = { [weak self] filter in
            self?.viewModel.filterTrackers(by: filter)
            guard let isActive = self?.viewModel.isFilterActive() else {
                return
            }
            self?.filterButton.backgroundColor = isActive ? .ypRed : .ypBlue
            if filter == .todayTrackers {
                self?.datePicker.setDate(Date(), animated: true)
            }
        }
        let navVC = UINavigationController(rootViewController: filterVC)
        present(navVC, animated: true)
    }
}

// MARK: - SearchController
extension TrackersViewController: UISearchResultsUpdating {
   func updateSearchResults(for searchController: UISearchController) {
        let text = searchController.searchBar.text
        viewModel.searchTrackers(with: text?.isEmpty == false ? text : nil)
    }
}

// MARK: - UICollectionViewDataSource & UICollectionViewDelegateFlowLayout
extension TrackersViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        guard indexPaths.count > 0 else {
            return nil
        }
        
        let indexPath = indexPaths[0]
        
        return UIContextMenuConfiguration(actionProvider: { actions in
            return UIMenu(children: [
                UIAction(title: NSLocalizedString("pin", comment: "")) { [weak self] _ in
                    
                },
                UIAction(title: NSLocalizedString("edit", comment: "")) { [weak self] _ in
                    guard let tracker = self?.viewModel.tracker(at: indexPath) else {
                        return
                    }
                    self?.editTapped(onTracker: tracker)
                },
                UIAction(title: NSLocalizedString("delete", comment: ""), attributes: .destructive) { [weak self] _ in
                    guard let tracker = self?.viewModel.tracker(at: indexPath) else {
                        return
                    }
                    self?.analyticsService.report(event: "click", params: ["screen": "main", "item" : "delete"])
                    self?.deleteTapped(tracker: tracker)
                }
            ])
        })
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        viewModel.numberOfSections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.numberOfItems(inSection: section)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let tracker = viewModel.tracker(at: indexPath),
              let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "Cell",
                for: indexPath
              ) as? TrackerCollectionViewCell
        else {
            assertionFailure("Failed to dequeue TrackerCollectionViewCell")
            return UICollectionViewCell()
        }
        
        let isCompleted = viewModel.isCompletedToday(trackerId: tracker.id)
        let completedDays = viewModel.completedDays(for: tracker.id)
        cell.configure(with: tracker, completedDays: completedDays, isCompletedToday: isCompleted)
        cell.onDoneButtonTapped = { [weak self] trackerId in
            guard let self = self else { return }
            analyticsService.report(event: "click", params: ["screen": "main", "item" : "track"])
            let success = self.viewModel.toggleTrackerCompletion(for: trackerId)
            if !success {
                self.showFutureDateRestriction()
            }
            if let indexPath = self.viewModel.indexPath(for: trackerId) {
                collectionView.reloadItems(at: [indexPath])
            }
        }
        return cell
    }
    
    func collectionView(
    _ collectionView: UICollectionView,
    willDisplay cell: UICollectionViewCell,
    forItemAt indexPath: IndexPath
) {
    cell.alpha = 0
    cell.transform = CGAffineTransform(scaleX: 0.85, y: 0.85).concatenating(
        CGAffineTransform(translationX: 0, y: 40)
    )
    
    UIView.animate(
        withDuration: 0.50,
        delay: 0.04 * Double(indexPath.item),
        usingSpringWithDamping: 0.7,
        initialSpringVelocity: 0.6,
        options: [.curveEaseOut]
    ) {
        cell.alpha = 1
        cell.transform = .identity
    }
}
    
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
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: TrackerHeaderView.reuseIdentifier,
                for: indexPath
              ) as? TrackerHeaderView
        else {
            return UICollectionReusableView()
        }
        let categoryTitle = viewModel.categoryTitle(for: indexPath.section)
        header.configure(with: categoryTitle)
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
