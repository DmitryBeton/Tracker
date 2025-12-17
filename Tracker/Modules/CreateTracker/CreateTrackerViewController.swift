//
//  CreateTrackerViewController.swift
//  Tracker
//
//  Created by Дмитрий Чалов on 09.11.2025.
//

import UIKit
import Logging

final class CreateTrackerViewController: UIViewController {
    // MARK: - Properties
    private let logger = Logger(label: "CreateTrackerViewController")
    
    // Callback для создания трекера
    var onCreateTracker: ((Tracker) -> Void)?
    
    // Data sources
    private let tableViewItems = ["Категория", "Расписание"]
    private let sectionsTitles = ["Emoji", "Цвет"]
    private let emojiCollectionViewItems = [
        "🙂", "😻", "🌺", "🐶", "❤️", "😱",
        "😇", "😡", "🥶", "🤔", "🙌", "🍔",
        "🥦", "🏓", "🥇", "🎸", "🏝️", "😪"
    ]
    private let colorsCollectionViewItems: [UIColor] = [
        .ypColorSelection1, .ypColorSelection2, .ypColorSelection3, .ypColorSelection4, .ypColorSelection5, .ypColorSelection6,
        .ypColorSelection7, .ypColorSelection8, .ypColorSelection9, .ypColorSelection10, .ypColorSelection11, .ypColorSelection12,
        .ypColorSelection13, .ypColorSelection14, .ypColorSelection15, .ypColorSelection16, .ypColorSelection17, .ypColorSelection18
    ]
    
    private var selectedSchedule: [WeekDay]?
    private var selectedEmoji: String = ""
    private var selectedColor: UIColor = .clear
    private var trackerName: String = ""
    private var tableViewTopConstraint: NSLayoutConstraint?
    
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

    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название трекера"
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
        return textField
    }()
    
    private lazy var warningLabel: UILabel = {
        let label = UILabel()
        label.text = "Ограничение 38 символов"
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
        button.setTitle("Отменить", for: .normal)
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
        button.setTitle("Создать", for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)
        button.backgroundColor = .ypGray
        button.layer.cornerRadius = 16
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(createTapped), for: .touchUpInside)
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
    
    // MARK: - Private methods
    private func createTracker() {
        logger.info("🎯 Начало создания трекера. Имя: '\(trackerName)', расписание: \(selectedSchedule != nil ? "установлено" : "не установлено")")
        
        guard !trackerName.isEmpty, let schedule = selectedSchedule else { return }
        
        let newTracker = Tracker(
            name: trackerName,
            color: selectedColor,
            emoji: selectedEmoji,
            schedule: schedule
        )
        
        logger.info("✅ Трекер создан: '\(trackerName)' с расписанием: \(schedule)")
        logger.debug("🔄 Трекер передан через колбэк")
        
        onCreateTracker?(newTracker)
        closeCreateTracker()
    }
    
    private func updateCreateButtonState() {
        let isEnabled = !trackerName.isEmpty && selectedSchedule != nil && !selectedEmoji.isEmpty && selectedColor != .clear
        addButton.isEnabled = isEnabled
        addButton.backgroundColor = isEnabled ? .ypBlack : .ypGray
    }
    
    private func showScheduleSelection() {
        let scheduleVC = ScheduleViewController()
        scheduleVC.delegate = self
        let navVC = UINavigationController(rootViewController: scheduleVC)
        present(navVC, animated: true)
        logger.info("✅ Экран расписания представлен модально")
    }
    
    private func showCategorySelection() {
        logger.info("📂 Запрос на показ экрана категорий (ЗАГЛУШКА)")
    }
    
    private func closeCreateTracker() {
        logger.info("🔒 Закрытие экрана создания трекера")
        dismiss(animated: true)
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        title = "Новая привычка"
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
                label.text = "Новая привычка"
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
            
            textField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
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
        
        if text.count > 38 {
            textField.text = String(text.prefix(38))
            warningLabel.isHidden = false
            tableViewTopConstraint?.constant = 62
        } else {
            warningLabel.isHidden = true
            tableViewTopConstraint?.constant = 24
        }
        
        trackerName = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        updateCreateButtonState()
    }
    
    @objc
    private func cancelTapped() {
        logger.info("❌ Пользователь отменил создание трекера")
        closeCreateTracker()
    }
    
    @objc
    private func createTapped() {
        logger.info("🎯 Пользователь нажал кнопку 'Создать'. Имя: '\(trackerName)', расписание: \(selectedSchedule?.map { $0.shortName }.joined(separator: ", ") ?? "Нет расписания")")
        createTracker()
    }
}

// MARK: - ScheduleViewControllerDelegate
extension CreateTrackerViewController: ScheduleViewControllerDelegate {
    func didSelectSchedule(_ schedule: [WeekDay]) {
        logger.info("✅ Получено новое расписание от ScheduleViewController: '\(schedule)'")
        selectedSchedule = schedule
        updateCreateButtonState()
        tableView.reloadData()
    }
}

// MARK: - UITextFieldDelegate
extension CreateTrackerViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        logger.debug("⌨️ Пользователь нажал Done на клавиатуре")
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - UITableViewDataSource
extension CreateTrackerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableViewItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        
        if let reusedCell = tableView.dequeueReusableCell(withIdentifier: "cell") {
            cell = reusedCell
        } else {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        }
        
        cell.textLabel?.text = tableViewItems[indexPath.row]
        cell.detailTextLabel?.text = nil
        cell.detailTextLabel?.textColor = .ypGray
        cell.backgroundColor = .ypBackground
        cell.accessoryType = .disclosureIndicator
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 16
        cell.selectionStyle = .none
        
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        
        if indexPath.row == 1, let schedule = selectedSchedule {
            if schedule.count == 7 {
                cell.detailTextLabel?.text = "Каждый день"
            } else {
                let sortedSchedule = schedule.sorted { $0.rawValue < $1.rawValue }
                cell.detailTextLabel?.text = sortedSchedule.map { $0.shortName }.joined(separator: ", ")
            }
        } else if indexPath.row == 0 {
            cell.detailTextLabel?.text = "Важное"
        }
        
        if indexPath.row == 0 {
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else {
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
}

// MARK: - UITableViewDelegate
extension CreateTrackerViewController: UITableViewDelegate {
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
        if indexPath.row == tableViewItems.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
    }
}

// MARK: - UICollectionViewDataSource
extension CreateTrackerViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sectionsTitles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return emojiCollectionViewItems.count
        }
        return colorsCollectionViewItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "emojiCell",
                for: indexPath
            ) as? EmojiCollectionViewCell else {
                assertionFailure("Unable to dequeue EmojiCollectionViewCell")
                return UICollectionViewCell()
            }
            cell.setEmoji(emojiCollectionViewItems[indexPath.row])
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "colorCell",
                for: indexPath
            ) as? ColorCollectionViewCell else {
                assertionFailure("Unable to dequeue ColorCollectionViewCell")
                return UICollectionViewCell()
            }
            cell.setColor(colorsCollectionViewItems[indexPath.row])
            return cell
        }
    }
}

// MARK: - UICollectionViewDelegate
extension CreateTrackerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            for i in 0..<emojiCollectionViewItems.count {
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
            selectedEmoji = emojiCollectionViewItems[indexPath.row]
            updateCreateButtonState()
        } else {
            for i in 0..<colorsCollectionViewItems.count {
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
            selectedColor = colorsCollectionViewItems[indexPath.row]
            updateCreateButtonState()
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
              ) as? TrackerHeaderView
        else {
            return UICollectionReusableView()
        }
                
        let category = sectionsTitles[indexPath.section]
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
