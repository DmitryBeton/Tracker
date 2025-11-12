//
//  ScheduleViewController.swift
//  Tracker
//
//  Created by Дмитрий Чалов on 11.11.2025.
//

import UIKit
import Logging

protocol ScheduleViewControllerDelegate: AnyObject {
    func didSelectSchedule(_ schedule: TrackerSchedule)
}

final class ScheduleViewController: UIViewController {
    // MARK: - Dependencies
    private let logger = Logger(label: "ScheduleViewController")
    weak var delegate: ScheduleViewControllerDelegate?

    // MARK: - Properties
    private var selectedDays: [Bool] = Array(repeating: false, count: 7)
    private let tableViewData: [String] = ["Понедельник", "Вторник", "Среда", "Четверг", "Пятница", "Суббота", "Воскресенье"]
    
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
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))
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
        
        view.addSubview(button)
        view.addSubview(tableView)
        
        tableView.dataSource = self
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
        selectedDays[sender.tag] = sender.isOn
        logger.debug("🔘 Изменен переключатель для '\(selectedDays[sender.tag])': \(!sender.isOn) -> \(sender.isOn)")
        logger.trace("📊 Текущее состояние дней: \(selectedDays)")
    }
    
    @objc // создает расписание и передает его в CreateTrackerViewController, после чего скрывает экран
    private func doneTapped() {
        logger.info("✅ Пользователь нажал 'Готово'.")
        let schedule = TrackerSchedule(
            monday: selectedDays[0],
            tuesday: selectedDays[1],
            wednesday: selectedDays[2],
            thursday: selectedDays[3],
            friday: selectedDays[4],
            saturday: selectedDays[5],
            sunday: selectedDays[6]
        )
        logger.debug("📅 Создано расписание: \(schedule.displayText)")
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
        
        let switcher = UISwitch()
        switcher.tag = indexPath.row
        switcher.isOn = selectedDays[indexPath.row]
        switcher.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)

        cell.accessoryView = switcher
        cell.textLabel?.text = tableViewData[indexPath.row]
        cell.backgroundColor = .ypBackground
        cell.selectionStyle = .none
        cell.layer.masksToBounds = true

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
        return 75
    }
}
