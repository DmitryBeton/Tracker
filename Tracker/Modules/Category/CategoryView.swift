//
//  CategoryView.swift
//  Tracker
//
//  Created by Дмитрий Чалов on 23.12.2025.
//

import UIKit

protocol CategoryViewDelegate: AnyObject {
    func didSelectCategory(_ category: String)
}

final class CategoryView: UIViewController {
    // MARK: - Properties
    private var viewModel: CategoryViewModel?
    
    private lazy var dataProvider: DataProviderProtocol? = {
        guard let trackerStore = (UIApplication.shared.delegate as? AppDelegate)?.trackerStore else { return  nil }
        do {
            try dataProvider = DataProvider(trackerStore)
            return dataProvider
        } catch {
            assertionFailure("Ошибка dataprovider в categoryView")
            return nil
        }
    }()
        
    private var tableViewData: [String] = []
    private var selectedCategory = ""
    weak var delegate: CategoryViewDelegate?

    // MARK: - UI Elements
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
        label.textAlignment = .center
        label.text = "Привычки и события можно\nобъединить по смыслу"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlack
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.isScrollEnabled = false
        tableView.backgroundColor = .ypWhite
        tableView.allowsMultipleSelection = false
        tableView.allowsMultipleSelectionDuringEditing = false
        return tableView
    }()

    private lazy var button: UIButton = {
        let button = UIButton()
        button.setTitle("Добавить категорию", for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)
        button.backgroundColor = .ypBlack
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(showCreateCategory), for: .touchUpInside)

        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        setupUI()
        setupConstraints()
        
        displayCategories()
        
    }
    
    // MARK: - Actions
    @objc
    private func showCreateCategory() {
        let createCategoryVC = CreateCategoryView()
        print("создаем замыкание")

        createCategoryVC.onCreateCategory = { [weak self] category in
            print("🔄 Получена новая категория из CreateCategory: '\(category)'")
            try? self?.dataProvider?.addCategory(category)
            self?.displayCategories()
        }

        let navVC = UINavigationController(rootViewController: createCategoryVC)
        present(navVC, animated: true)
    }

    // MARK: - Public methods
    func initialize(viewModel: CategoryViewModel) {
        self.viewModel = viewModel
        bind()
    }
    
    // MARK: - Private methods
    private func saveCategory() {
        delegate?.didSelectCategory(selectedCategory)
        dismiss(animated: true)
    }

    private func displayCategories() {
        tableViewData = dataProvider?.fetchAllCategories() ?? []
        if tableViewData.isEmpty {
            showEmptyState()
        } else {
            hideEmptyState()
        }
        tableView.reloadData()
    }
    
    private func showEmptyState() {
        guard emptyStateView.isHidden else { return }

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
        guard !emptyStateView.isHidden else { return }

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

    private func bind() {
        guard let viewModel = viewModel else { return }
        
        // сделать
    }

    private func setupUI() {
        view.addSubview(tableView)
        view.addSubview(emptyStateView)
        emptyStateView.addSubview(dizzyImage)
        emptyStateView.addSubview(label)
        view.addSubview(button)
        
        tableView.dataSource = self
        tableView.delegate = self

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
                label.text = "Категории"
                label.font = titleFont
                label.textColor = .ypBlack
                label.textAlignment = .center
                return label
            }()
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            button.heightAnchor.constraint(equalToConstant: 60),
            
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: button.topAnchor, constant: -24),
            
            emptyStateView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            emptyStateView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 232),
            emptyStateView.bottomAnchor.constraint(equalTo: button.topAnchor, constant: 232),
            
            dizzyImage.topAnchor.constraint(equalTo: emptyStateView.topAnchor),
            dizzyImage.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            
            label.topAnchor.constraint(equalTo: dizzyImage.bottomAnchor, constant: 8),
            label.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),

        ])

    }
}

// MARK: - UITableViewDataSource
extension CategoryView: UITableViewDataSource {
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
        cell.textLabel?.text = tableViewData[indexPath.row]

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

extension CategoryView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
            if indexPath.row == tableViewData.count - 1 {
                cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
            } else {
                cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
            }
        }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        
        if cell.accessoryType == .checkmark {
            cell.accessoryType = .none
            selectedCategory = ""
        } else {
            cell.accessoryType = .checkmark
            selectedCategory = tableViewData[indexPath.row]
        }
        
        saveCategory()

    }
}
