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
        label.text = "Анализировать пока нечего"
        label.textColor = .ypBlack
        return label
    }()
    
    private let tableView: UITableView = {
        let table = UITableView()
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
        noDataStateView.isHidden = true
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = "Cтатистика"
        
        view.backgroundColor = .ypWhite

        view.addSubview(noDataStateView)
        noDataStateView.addSubview(noDataImage)
        noDataStateView.addSubview(noDataLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            noDataStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noDataStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            noDataImage.topAnchor.constraint(equalTo: noDataStateView.topAnchor),
            noDataImage.centerXAnchor.constraint(equalTo: noDataStateView.centerXAnchor),
            
            noDataLabel.topAnchor.constraint(equalTo: noDataImage.bottomAnchor, constant: 8),
            noDataLabel.centerXAnchor.constraint(equalTo: noDataImage.centerXAnchor),
        ])
    }
    
}
