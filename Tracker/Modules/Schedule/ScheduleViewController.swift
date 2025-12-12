//
//  ScheduleViewController.swift
//  Tracker
//
//  Created by Дмитрий Чалов on 11.11.2025.
//

import UIKit
import Logging

protocol ScheduleViewControllerDelegate: AnyObject {
    func didSelectSchedule(_ schedule: Set<WeekDay>)
}

final class ScheduleViewController: UIViewController {
    // MARK: - Dependencies
    private let logger = Logger(label: "ScheduleViewController")
    weak var delegate: ScheduleViewControllerDelegate?
    
    // MARK: - Properties
    private var selectedDays: Set<WeekDay> = []
    private let tableViewData: [WeekDay] = WeekDay.allCases
    
    // MARK: - UI Elements
    private lazy var button: UIButton = {
        let button = UIButton()
        button.setTitle("Готово", for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)
        button.backgroundColor = .ypBlack
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        return button
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.isScrollEnabled = false
        tableView.backgroundColor = .ypWhite
        return tableView
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        logger.info("✅ Экран расписания готов к работе.")
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        title = "Расписание"
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
                label.text = "Расписание"
                label.font = titleFont
                label.textColor = .ypBlack
                label.textAlignment = .center
                return label
            }()
        }

        
        view.addSubview(button)
        view.addSubview(tableView)
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            button.heightAnchor.constraint(equalToConstant: 60),
            
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            tableView.heightAnchor.constraint(equalToConstant: 525)
        ])
    }
    
    // MARK: - Actions
    @objc // изменяет состояние switch вкл/выкл
    private func switchChanged(_ sender: UISwitch) {
        let day = tableViewData[sender.tag]
        
        if sender.isOn {
            selectedDays.insert(day)
        } else {
            selectedDays.remove(day)
        }

        logger.debug("🔘 Изменен переключатель для '\(day.rawValue)': \(!sender.isOn) -> \(sender.isOn)")
        logger.trace("📊 Текущее состояние дней: \(selectedDays)")
    }
    
    @objc // создает расписание и передает его в CreateTrackerViewController, после чего скрывает экран
    private func doneTapped() {
        logger.info("✅ Пользователь нажал 'Готово'.")
        let schedule = selectedDays
        logger.debug("📅 Создано расписание: \(selectedDays)")
        logger.info("🔄 Передача расписания делегату.")
        delegate?.didSelectSchedule(schedule)
        dismiss(animated: true)
        logger.info("🔒 Экран расписания закрывается")
    }
}

// MARK: - UITableViewDataSource
extension ScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableViewData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        
        if let reusedCell = tableView.dequeueReusableCell(withIdentifier: "cell") {
            cell = reusedCell
        } else {
            cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        }
        let day = tableViewData[indexPath.row]
        
        let switcher = UISwitch()
        switcher.tag = indexPath.row
        switcher.isOn = selectedDays.contains(day)
        switcher.onTintColor = .ypBlue
        switcher.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
        
        cell.accessoryView = switcher
        cell.textLabel?.text = day.fullName
        cell.backgroundColor = .ypBackground
        cell.selectionStyle = .none
        cell.layer.masksToBounds = true
        
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)

        if indexPath.row == 0 {
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else if indexPath.row == tableViewData.count - 1 {
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else {
            cell.layer.cornerRadius = 0
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
}

extension ScheduleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
            if indexPath.row == tableViewData.count - 1 {
                cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
            } else {
                cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
            }
        }
}
