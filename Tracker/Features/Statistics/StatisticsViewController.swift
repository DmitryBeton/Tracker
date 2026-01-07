//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by Дмитрий Чалов on 31.10.2025.
//

import UIKit

final class StatisticsViewController: UIViewController {
    // MARK: - Properties
    private let viewModel: StatisticsViewModel
    
    // MARK: - UI Elements
    private let noDataStateView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let noDataImage: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.image = UIImage(resource: .noData)
        return image
    }()
    
    private let noDataLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = NSLocalizedString("no_data_for_analysis", comment: "")
        label.textColor = .ypBlack
        return label
    }()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = .ypWhite
        table.rowHeight = 90
        return table
    }()
    // MARK: - Initialization
    init(viewModel: StatisticsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupConstraints()
        noDataStateView.isHidden = !viewModel.isEmpty
        tableView.isHidden = viewModel.isEmpty

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        noDataStateView.isHidden = !viewModel.isEmpty
        tableView.isHidden = viewModel.isEmpty
        tableView.reloadData()
    }


    // MARK: - Setup
    private func setupUI() {
        title = NSLocalizedString("statistics", comment: "")
        
        view.backgroundColor = .ypWhite

        view.addSubview(tableView)
        view.addSubview(noDataStateView)
        noDataStateView.addSubview(noDataImage)
        noDataStateView.addSubview(noDataLabel)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(
            StatisticsTableViewCell.self,
            forCellReuseIdentifier: StatisticsTableViewCell.reuseIdentifier
        )
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            noDataStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noDataStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            noDataImage.topAnchor.constraint(equalTo: noDataStateView.topAnchor),
            noDataImage.centerXAnchor.constraint(equalTo: noDataStateView.centerXAnchor),
            
            noDataLabel.topAnchor.constraint(equalTo: noDataImage.bottomAnchor, constant: 8),
            noDataLabel.centerXAnchor.constraint(equalTo: noDataImage.centerXAnchor),
            
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 77),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            tableView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -12),
            tableView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 12),
        ])
    }
    
    // MARK: - Public Methods
    func changeStateView(isHidden: Bool) {
        noDataStateView.isHidden = isHidden
    }
}

extension StatisticsViewController: UITableViewDataSource & UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        4
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: StatisticsTableViewCell.reuseIdentifier,
            for: indexPath
        ) as? StatisticsTableViewCell else {
            assertionFailure("Failed to dequeue StatisticsTableViewCell")
            return UITableViewCell()
        }
        
        let stat = viewModel.statInfo(for: indexPath.section)
        cell.configuration(count: stat.value, text: stat.description)
        return cell
    }

    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        12
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        UIView()
    }
    
}
