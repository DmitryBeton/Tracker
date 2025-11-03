//
//  TrackerListViewController.swift
//  Tracker
//
//  Created by Дмитрий Чалов on 31.10.2025.
//

import UIKit

final class TrackerListViewController: UIViewController {
    // MARK: - Properties
    var categories: [TrackerCategory] = []
    var completedTrackers: [TrackerRecord] = []
    
    // MARK: - UI Elements
    private let dizzyImage: UIImageView = {
        let image = UIImageView(image: UIImage(resource: .dizzy))
        return image
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlack
        return label
    }()
    
    private let navContainer: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(resource: .addTracker), for: .normal)
        button.tintColor = .ypBlack
        button.addTarget(self, action: #selector(didTapAddButton), for: .touchUpInside)
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Трекеры"
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.textColor = .ypBlack
        label.textAlignment = .left
        return label
    }()
    
    private lazy var dateButton: UIButton = {
        var configuration = UIButton.Configuration.plain()
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12)
        
        let button = UIButton(configuration: configuration, primaryAction: nil)
        button.setTitle(getFormattedDate(), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        button.tintColor = .ypBlack
        button.backgroundColor = .ypBackground
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(didTapDateButton), for: .touchUpInside)
        return button
    }()
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Поиск"
        searchBar.backgroundImage = UIImage()
        return searchBar
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupConstrains()
    }
    
    // MARK: - Private methods
    @objc private func didTapAddButton() {
        print("Add button tapped")
    }
    
    @objc private func didTapDateButton() {
        print("Date button tapped")
    }
    
    private func getFormattedDate() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "dd.MM.yy"
        return formatter.string(from: Date())
    }
    
    // MARK: - SetupUI
    private func setupUI() {
        view.backgroundColor = .ypBackground
        
        view.addSubview(navContainer)
        navContainer.addSubview(addButton)
        navContainer.addSubview(titleLabel)
        navContainer.addSubview(dateButton)
        view.addSubview(searchBar)
        view.addSubview(dizzyImage)
        view.addSubview(label)
    }
    
    private func setupConstrains() {
        navContainer.translatesAutoresizingMaskIntoConstraints = false
        addButton.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        dateButton.translatesAutoresizingMaskIntoConstraints = false
        dizzyImage.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Nav Container
            navContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navContainer.heightAnchor.constraint(equalToConstant: 140),

            // Add Button (слева вверху)
            addButton.topAnchor.constraint(equalTo: navContainer.topAnchor, constant: 16),
            addButton.leadingAnchor.constraint(equalTo: navContainer.leadingAnchor, constant: 16),
            addButton.widthAnchor.constraint(equalToConstant: 44),
            addButton.heightAnchor.constraint(equalToConstant: 44),
            
            // Date Button (справа вверху)
            dateButton.topAnchor.constraint(equalTo: navContainer.topAnchor, constant: 16),
            dateButton.trailingAnchor.constraint(equalTo: navContainer.trailingAnchor, constant: -16),
            dateButton.heightAnchor.constraint(equalToConstant: 34),

            // Title Label (под кнопкой добавления, слева)
            titleLabel.topAnchor.constraint(equalTo: addButton.bottomAnchor, constant: 1),
            titleLabel.leadingAnchor.constraint(equalTo: navContainer.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: navContainer.trailingAnchor, constant: -16),
            
            // Search Bar (под заголовком)
            searchBar.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 7),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            // Остальные элементы
            dizzyImage.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            dizzyImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            dizzyImage.widthAnchor.constraint(equalToConstant: 80),
            dizzyImage.heightAnchor.constraint(equalToConstant: 80),

            label.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            label.topAnchor.constraint(equalTo: dizzyImage.bottomAnchor, constant: 8)
	        ])
    }
}
