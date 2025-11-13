//
//  CreateTrackerViewController.swift
//  Tracker
//
//  Created by Дмитрий Чалов on 09.11.2025.
//

import UIKit
import Logging

final class CreateTrackerViewController: UIViewController {
    // MARK: - Dependencies
    private var presenter: CreateTrackerPresenterProtocol?
    private let logger = Logger(label: "CreateTrackerViewController")
    
    // MARK: - Properties
    private let tableViewItems = ["Категория", "Расписание"]
    private var selectedSchedule: TrackerSchedule?
    private var trackerName: String = ""
    
    // MARK: - UI Elements
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
        return textField
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.isScrollEnabled = false
        tableView.sectionIndexBackgroundColor = .ypBackground
        tableView.translatesAutoresizingMaskIntoConstraints = false
//        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))
        return tableView
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
    
    func configure(with presenter: CreateTrackerPresenterProtocol) {
        self.presenter = presenter
        logger.info("🎯 Presenter сконфигурирован")
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
        
        view.addSubview(textField)
        view.addSubview(cancelButton)
        view.addSubview(addButton)
        view.addSubview(tableView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            textField.heightAnchor.constraint(equalToConstant: 75),
            textField.widthAnchor.constraint(equalToConstant: 343),
            textField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            tableView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 24),
            tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tableView.widthAnchor.constraint(equalToConstant: 343),
            tableView.heightAnchor.constraint(equalToConstant: 150),
            
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
    
    // MARK: - Private methods
    // Обновление состояния кнопки (ВКЛ, если заполнены все поля)
    private func updateCreateButtonState() {
        let isEnabled = !trackerName.isEmpty && selectedSchedule != nil
        addButton.isEnabled = isEnabled
        addButton.backgroundColor = isEnabled ? .ypBlack : .ypGray
    }
    
    // MARK: - Actions
    // Закрывает клавиатуру по нажатию на экран
    @objc
    private func handleTap() {
        logger.trace("👆 Пользователь тапнул по экрану для скрытия клавиатуры")
        view.endEditing(true)
    }
    
    // Сохраненяет название трекера из TextField
    @objc
    private func textFieldDidChange() {
        trackerName = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        updateCreateButtonState()
    }
    
    // Закрывает экран создания трекера
    @objc
    private func cancelTapped() {
        logger.info("❌ Пользователь отменил создание трекера")
        dismiss(animated: true)
    }
    
    // говорит presentr'y о создании трекера
    @objc
    private func createTapped() {
        logger.info("🎯 Пользователь нажал кнопку 'Создать'. Имя: '\(trackerName)', расписание: \(selectedSchedule?.displayText ?? "нет")")
        presenter?.didTapCreate(name: trackerName, schedule: selectedSchedule)
    }
}

// MARK: - CreateTrackerViewProtocol
extension CreateTrackerViewController: CreateTrackerViewProtocol {
    func showCategorySelection() {
        logger.info("📂 Запрос на показ экрана категорий (ЗАГЛУШКА)")
    }
    
    func showScheduleSelection() {
        let scheduleVC = ScheduleViewController()
        scheduleVC.delegate = self
        let navVC = UINavigationController(rootViewController: scheduleVC)
        present(navVC, animated: true)
        logger.info("✅ Экран расписания представлен модально")
    }
    
    func closeCreateTracker() {
        logger.info("🔒 Закрытие экрана создания трекера")
        dismiss(animated: true)
    }
}

// MARK: - ScheduleViewControllerDelegate
extension CreateTrackerViewController: ScheduleViewControllerDelegate {
    // Сохраняет расписание, после чего обновляет состояние кнопки создания трекера и перезагружает таблицу
    func didSelectSchedule(_ schedule: TrackerSchedule) {
        logger.info("✅ Получено новое расписание от ScheduleViewController: '\(schedule.displayText)'")
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
            cell.detailTextLabel?.text = schedule.displayText
        } else if indexPath.row == 0 {
            cell.detailTextLabel?.text = "Важное" // Фиксированная категория
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
