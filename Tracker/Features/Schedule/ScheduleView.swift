//
//  ScheduleView.swift
//  Tracker
//
//  Created by Дмитрий Чалов on 01.01.2026.
//

import UIKit
import Logging

protocol ScheduleViewControllerDelegate: AnyObject {
    func didSelectSchedule(_ schedule: [WeekDay])
}

final class ScheduleView: UIViewController {
    
    // MARK: - Properties
    weak var delegate: ScheduleViewControllerDelegate?
    private var viewModel: ScheduleViewModelProtocol?
    
    private let logger = Logger(label: "ScheduleView")
    
    // MARK: - UI Elements
    private lazy var button: UIButton = {
        let button = UIButton()
        let text = NSLocalizedString("ready", comment: "")
        button.setTitle(text, for: .normal)
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
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }
    
    deinit {
        logger.info("🔒 ScheduleView deallocated")
    }
    
    // MARK: - Public Methods
    func initialize(viewModel: ScheduleViewModelProtocol) {
        self.viewModel = viewModel
        bind()
    }
    
    // MARK: - Setup
    private func bind() {
        guard let viewModel = viewModel else { return }
        
        viewModel.onScheduleReady = { [weak self] schedule in
            self?.delegate?.didSelectSchedule(schedule)
            self?.dismiss(animated: true)
        }
    }
    
    private func setupUI() {
        let text = NSLocalizedString("schedule", comment: "")
        title = text
        view.backgroundColor = .ypWhite
        
        setupNavigationBar()
        view.addSubview(button)
        view.addSubview(tableView)
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func setupNavigationBar() {
        guard let navigationController = navigationController else { return }
        
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
            label.text = NSLocalizedString("schedule", comment: "")
            label.font = titleFont
            label.textColor = .ypBlack
            label.textAlignment = .center
            return label
        }()
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
    @objc
    private func switchChanged(_ sender: UISwitch) {
        viewModel?.didToggleSwitch(at: sender.tag, isOn: sender.isOn)
    }
    
    @objc
    private func doneTapped() {
        logger.info("✅ Пользователь нажал 'Готово'.")
        viewModel?.didTapDoneButton()
    }
}

// MARK: - UITableViewDataSource & Delegate
extension ScheduleView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel?.numberOfRows() ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let viewModel = viewModel,
              let day = viewModel.day(at: indexPath.row) else {
            return UITableViewCell()
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let switcher = UISwitch()
        switcher.tag = indexPath.row
        switcher.isOn = viewModel.isDaySelected(day)
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
        } else if indexPath.row == (viewModel.numberOfRows() - 1) {
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
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let viewModel = viewModel else { return }
        
        if indexPath.row == viewModel.numberOfRows() - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
    }
}
