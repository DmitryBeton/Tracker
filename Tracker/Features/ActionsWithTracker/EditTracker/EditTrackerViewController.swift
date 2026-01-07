//
//  CreateTrackerViewController.swift
//  Tracker
//
//  Created by Дмитрий Чалов on 09.11.2025.
//

import UIKit
import Logging

final class EditTrackerViewController: UIViewController {
    
    // MARK: - Dependences
    private let logger = Logger(label: "CreateTrackerViewController")
    private var viewModel: EditTrackerViewModel?
    
    // MARK: - Properties
    private var tableViewTopConstraint: NSLayoutConstraint?
    var onEditTracker: Binding<Tracker>?
    
    // MARK: - UI Elements
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var daysLabel: UILabel = {
        let label = UILabel()
        
        let daysString = String.localizedStringWithFormat(
            NSLocalizedString("countOfDays", comment: "Number of completed days"),
            viewModel?.daysCompleted() ?? 0
        )
        
        label.text = daysString
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        
        label.font = .systemFont(ofSize: 32, weight: .bold)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = 38
        paragraphStyle.maximumLineHeight = 38
        paragraphStyle.alignment = .center
        
        label.attributedText = NSAttributedString(
            string: daysString,
            attributes: [
                .font: label.font as Any,
                .paragraphStyle: paragraphStyle,
                .kern: 0
            ]
        )
        
        return label
    }()
    
    private lazy var textField: UITextField = {
        let textField = UITextField()
        let text = NSLocalizedString("enter_name_of_tracker", comment: "")
        textField.placeholder = text
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = .ypBackground
        textField.layer.cornerRadius = 16
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftViewMode = .always
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        textField.returnKeyType = .done
        textField.delegate = self
        textField.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        textField.enablesReturnKeyAutomatically = true
        textField.clearButtonMode = .whileEditing
        textField.text? = viewModel?.currentName ?? "❌ Error ❌"
        return textField
    }()
    
    private lazy var warningLabel: UILabel = {
        let label = UILabel()
        let text = NSLocalizedString("symbol_limit", comment: "")
        label.text = text
        label.textColor = .ypRed
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.isScrollEnabled = false
        tableView.sectionIndexBackgroundColor = .ypBackground
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.register(EmojiCollectionViewCell.self, forCellWithReuseIdentifier: "emojiCell")
        cv.register(ColorCollectionViewCell.self, forCellWithReuseIdentifier: "colorCell")
        cv.register(
            TrackerHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TrackerHeaderView.reuseIdentifier
        )
        cv.isScrollEnabled = false
        cv.backgroundColor = .ypWhite
        cv.allowsMultipleSelection = true
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        let text = NSLocalizedString("cancel", comment: "")
        button.setTitle(text, for: .normal)
        button.setTitleColor(UIColor.ypRed, for: .normal)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.ypRed.cgColor
        button.backgroundColor = .clear
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var addButton: UIButton = {
        let button = UIButton()
        let text = NSLocalizedString("save", comment: "")
        button.setTitle(text, for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)
        button.backgroundColor = .ypGray
        button.layer.cornerRadius = 16
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(editTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        logger.info("🔄 Экран создания трекера загружается")
        setupUI()
        setupConstraints()
        setupGestureRecognizer()
        logger.info("✅ Экран создания трекера готов к работе")
    }
    
    // MARK: - Initialization
    func initialize(viewModel: EditTrackerViewModel) {
        self.viewModel = viewModel
        bind()
    }
    
    private func bind() {
        guard let viewModel = viewModel else { return }
        
        viewModel.onNameStateChange = { [weak self] nameState in
            guard let self = self, let nameState = nameState else { return }
            
            self.textField.text = nameState.text
            if let warning = nameState.warning {
                self.textField.text = String(self.textField.text!.prefix(38))
                self.warningLabel.isHidden = false
                self.warningLabel.text = warning
                self.tableViewTopConstraint?.constant = 62
            } else {
                self.warningLabel.isHidden = true
                self.tableViewTopConstraint?.constant = 24
            }
        }
        
        viewModel.onCreateButtonStateChange = { [weak self] isEnabled in
            self?.addButton.isEnabled = isEnabled
            self?.addButton.backgroundColor = isEnabled ? .ypBlack : .ypGray
        }
        
        viewModel.onCategoryStateChange = { [weak self] category in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) {
                    cell.detailTextLabel?.text = category
                }
            }
            
        }
        
        viewModel.onScheduleStateChange = { [weak self] scheduleText in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let cell = self.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) {
                    cell.detailTextLabel?.text = scheduleText
                }
            }
        }
    }
    
    // MARK: - Private methods
    private func showScheduleSelection() {
        let scheduleModel = ScheduleModel()
        let scheduleViewModel = ScheduleViewModel(for: scheduleModel)
        let scheduleView = ScheduleView()
        scheduleView.initialize(viewModel: scheduleViewModel)
        scheduleView.delegate = self
        
        let navigationController = UINavigationController(rootViewController: scheduleView)
        present(navigationController, animated: true)
        
        logger.info("✅ Экран расписания представлен модально")
    }
    
    private func showCategorySelection() {
        logger.info("📂 Запрос на показ экрана категорий")
        
        guard let trackerStore = (UIApplication.shared.delegate as? AppDelegate)?.trackerStore else {
            assertionFailure("trackerStore not found")
            return
        }
        
        let dataProvider: DataProviderProtocol
        do {
            dataProvider = try DataProvider(trackerStore)
        } catch {
            assertionFailure("DataProvider init failed")
            return
        }
        
        let categoryModel = CategoryModel(dataProvider: dataProvider)
        let categoryViewModel = CategoryViewModel(model: categoryModel)
        let categoryVC = CategoryView(viewModel: categoryViewModel)
        categoryVC.delegate = self
        
        let navVC = UINavigationController(rootViewController: categoryVC)
        present(navVC, animated: true)
    }
    
    private func closeCreateTracker() {
        logger.info("🔒 Закрытие экрана создания трекера")
        dismiss(animated: true)
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        let titleText = NSLocalizedString("edit_tracker", comment: "")
        title = titleText
        view.backgroundColor = .ypWhite
        
        if let navigationController = navigationController {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .ypWhite
            appearance.shadowColor = .clear
            
            let titleFont = UIFont.systemFont(ofSize: 16, weight: .medium)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.minimumLineHeight = 22
            paragraphStyle.maximumLineHeight = 22
            paragraphStyle.alignment = .center
            
            appearance.titleTextAttributes = [
                .foregroundColor: UIColor.ypBlack,
                .font: titleFont,
                .paragraphStyle: paragraphStyle
            ]
            
            navigationController.navigationBar.standardAppearance = appearance
            navigationController.navigationBar.scrollEdgeAppearance = appearance
            navigationController.navigationBar.compactAppearance = appearance
            
            navigationItem.titleView = {
                let label = UILabel()
                label.text = titleText
                label.font = titleFont
                label.textColor = .ypBlack
                label.textAlignment = .center
                return label
            }()
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(daysLabel)
        contentView.addSubview(textField)
        contentView.addSubview(warningLabel)
        contentView.addSubview(tableView)
        contentView.addSubview(collectionView)
        
        view.addSubview(cancelButton)
        view.addSubview(addButton)
    }
    
    private func setupConstraints() {
        tableViewTopConstraint = tableView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 24)
        tableViewTopConstraint?.isActive = true
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: cancelButton.topAnchor, constant: -16),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            daysLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 24),
            daysLabel.heightAnchor.constraint(equalToConstant: 38),
            daysLabel.widthAnchor.constraint(equalToConstant: 343),
            daysLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            
            textField.topAnchor.constraint(equalTo: daysLabel.bottomAnchor, constant: 40),
            textField.heightAnchor.constraint(equalToConstant: 75),
            textField.widthAnchor.constraint(equalToConstant: 343),
            textField.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            warningLabel.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 8),
            warningLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            warningLabel.heightAnchor.constraint(equalToConstant: 22),
            
            tableView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            tableView.widthAnchor.constraint(equalToConstant: 343),
            tableView.heightAnchor.constraint(equalToConstant: 150),
            
            collectionView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 32),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 500),
            
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            cancelButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            cancelButton.widthAnchor.constraint(equalToConstant: 166),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            addButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            addButton.widthAnchor.constraint(equalToConstant: 161),
            addButton.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
    
    private func setupGestureRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Actions
    @objc
    private func handleTap() {
        logger.trace("👆 Пользователь тапнул по экрану для скрытия клавиатуры")
        view.endEditing(true)
    }
    
    @objc
    private func textFieldDidChange() {
        guard let text = textField.text else { return }
        viewModel?.didEnterName(text)
    }
    
    @objc
    private func cancelTapped() {
        logger.info("❌ Пользователь отменил создание трекера")
        closeCreateTracker()
    }
    
    @objc
    private func editTapped() {
        guard let viewModel = viewModel,
              let tracker = viewModel.editTracker()
        else {
            return
        }
        
        logger.info("🎯 Изменение трекера: '\(tracker.name)'")
        onEditTracker?(tracker)
        closeCreateTracker()
    }
}

// MARK: - ScheduleViewControllerDelegate
extension EditTrackerViewController: ScheduleViewControllerDelegate {
    func didSelectSchedule(_ schedule: [WeekDay]) {
        logger.info("✅ Получено новое расписание: '\(schedule)'")
        viewModel?.didSelectSchedule(schedule)
    }
}

// MARK: - CategoryViewDelegate
extension EditTrackerViewController: CategoryViewDelegate {
    func didSelectCategory(_ category: String) {
        logger.info("✅ Получен заголовок категории: '\(category)'")
        viewModel?.didSelectCategory(category)
    }
}

// MARK: - UITextFieldDelegate
extension EditTrackerViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        logger.debug("⌨️ Пользователь нажал Done на клавиатуре")
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - UITableViewDataSource
extension EditTrackerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel?.tableViewItems.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        
        if let reusedCell = tableView.dequeueReusableCell(withIdentifier: "cell") {
            cell = reusedCell
        } else {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        }
        
        guard let viewModel = viewModel else { return cell }
        
        cell.textLabel?.text = viewModel.tableViewItems[indexPath.row]
        cell.detailTextLabel?.text = nil
        cell.detailTextLabel?.textColor = .ypGray
        cell.backgroundColor = .ypBackground
        cell.accessoryType = .disclosureIndicator
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 16
        cell.selectionStyle = .none
        
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        
        // Здесь детали будут обновляться через binding
        
        if indexPath.row == 0 {
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            cell.detailTextLabel?.text = viewModel.currentCategory
        } else {
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            cell.detailTextLabel?.text = viewModel.displayedScheduleText(viewModel.currentSchedule)
            
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
}

// MARK: - UITableViewDelegate
extension EditTrackerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case 0:
            showCategorySelection()
        case 1:
            showScheduleSelection()
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == (viewModel?.tableViewItems.count ?? 0) - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
    }
}

// MARK: - UICollectionViewDataSource
extension EditTrackerViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel?.sectionsTitles.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let viewModel = viewModel else { return 0 }
        
        if section == 0 {
            return viewModel.emojiItems.count
        }
        return viewModel.colorItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let viewModel = viewModel else { return UICollectionViewCell() }
        
        if indexPath.section == 0 {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "emojiCell",
                for: indexPath
            ) as? EmojiCollectionViewCell else {
                assertionFailure("Unable to dequeue EmojiCollectionViewCell")
                return UICollectionViewCell()
            }
            let emoji = viewModel.emojiItems[indexPath.row]
            let selectedEmoji = viewModel.currentEmoji
            cell.setEmoji(emoji)
            if emoji == selectedEmoji {
                cell.isSelected = true
                cell.setSelected(true)
            }
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "colorCell",
                for: indexPath
            ) as? ColorCollectionViewCell else {
                assertionFailure("Unable to dequeue ColorCollectionViewCell")
                return UICollectionViewCell()
            }
            let color = viewModel.colorItems[indexPath.row]
            let selectedColor = viewModel.currentColor
            cell.setColor(viewModel.colorItems[indexPath.row])
            if let color = color.cgColor.components,
               let selectedColor = selectedColor?.cgColor.components,
               color == selectedColor{
                cell.isSelected = true
                cell.setSelected(true)
            }
            return cell
        }
    }
}

// MARK: - UICollectionViewDelegate
extension EditTrackerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let viewModel = viewModel else { return }
        
        if indexPath.section == 0 {
            // Deselect other emoji cells
            for i in 0..<viewModel.emojiItems.count {
                if i != indexPath.item {
                    let otherIndexPath = IndexPath(item: i, section: 0)
                    collectionView.deselectItem(at: otherIndexPath, animated: false)
                    if let cell = collectionView.cellForItem(at: otherIndexPath) as? EmojiCollectionViewCell {
                        cell.setSelected(false)
                    }
                }
            }
            
            guard let cell = collectionView.cellForItem(at: indexPath) as? EmojiCollectionViewCell else { return }
            cell.setSelected(true)
            viewModel.didSelectEmoji(viewModel.emojiItems[indexPath.row])
        } else {
            // Deselect other color cells
            for i in 0..<viewModel.colorItems.count {
                if i != indexPath.item {
                    let otherIndexPath = IndexPath(item: i, section: 1)
                    collectionView.deselectItem(at: otherIndexPath, animated: false)
                    if let cell = collectionView.cellForItem(at: otherIndexPath) as? ColorCollectionViewCell {
                        cell.setSelected(false)
                    }
                }
            }
            
            guard let cell = collectionView.cellForItem(at: indexPath) as? ColorCollectionViewCell else { return }
            cell.setSelected(true)
            viewModel.didSelectColor(viewModel.colorItems[indexPath.row])
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            guard let cell = collectionView.cellForItem(at: indexPath) as? EmojiCollectionViewCell else { return }
            cell.setSelected(false)
        } else {
            guard let cell = collectionView.cellForItem(at: indexPath) as? ColorCollectionViewCell else { return }
            cell.setSelected(false)
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        CGSize(width: 52, height: 52)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        UIEdgeInsets(top: 16, left: 28, bottom: 16, right: 16)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        5
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
              ) as? TrackerHeaderView,
              let viewModel = viewModel
        else {
            return UICollectionReusableView()
        }
        
        let category = viewModel.sectionsTitles[indexPath.section]
        header.configure(with: category)
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
