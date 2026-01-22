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
    private let viewModel: CategoryViewModelProtocol
    weak var delegate: CategoryViewDelegate?
    
    // MARK: - UI
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.isScrollEnabled = false
        tableView.backgroundColor = .ypWhite
        return tableView
    }()
    
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
        let text = Localizable.Other.canBeCombinedIntoCategories.localized
        label.textAlignment = .center
        label.text = text
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlack
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let addButton: UIButton = {
        let button = UIButton()
        let text = Localizable.Other.addCategory.localized
        button.setTitle(text, for: .normal)
        button.backgroundColor = .ypBlack
        button.setTitleColor(.ypWhite, for: .normal)
        button.layer.cornerRadius = 16
        return button
    }()
    
    // MARK: - Init
    init(viewModel: CategoryViewModel) {
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
        bind()
        viewModel.loadCategories()
    }
    
    // MARK: - Bind
    private func bind() {
        viewModel.onDataChanged = { [weak self] _ in
            self?.tableView.reloadData()
        }
        
        viewModel.onEmptyStateChanged = { [weak self] isEmpty in
            self?.emptyStateView.isHidden = !isEmpty
        }
        
        viewModel.onCategorySelected = { [weak self] category in
            self?.delegate?.didSelectCategory(category)
            self?.dismiss(animated: true)
        }
    }
    
    // MARK: - Actions
    @objc private func addTapped() {
        let createVM = CreateCategoryViewModel()
        let createVC = CreateCategoryView(viewModel: createVM)
        
        createVC.onCreateCategory = { [weak self] name in
            self?.viewModel.addCategory(name)
        }
        
        present(UINavigationController(rootViewController: createVC), animated: true)
    }
    
    private func editTapped(at indexPath: IndexPath, titleNow: String) {
        let editVM = EditCategoryViewModel()
        let editVC = EditCategoryView(viewModel: editVM, title: titleNow)
        
        editVC.onEditCategory = { [weak self] name in
            print("EditView -> createTapped() -> \(name)")
            self?.viewModel.editCategory(at: indexPath, to: name)
        }
        
        present(UINavigationController(rootViewController: editVC), animated: true)
    }
    
    private func deleteTapped(index: IndexPath) {
        let alert = UIAlertController(
            title: "",
            message: Localizable.Edit.deleteCategory.localized,
            preferredStyle: .actionSheet
        )
        alert.addAction(UIAlertAction(title: Localizable.Edit.delete.localized, style: .destructive) { [weak self] _ in self?.viewModel.deleteCategory(at: index) })
        alert.addAction(UIAlertAction(title: Localizable.Other.cancel.localized, style: .default))
        
        present(alert, animated: true)
        
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        let text = Localizable.Other.category.localized
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
                label.text = text
                label.font = titleFont
                label.textColor = .ypBlack
                label.textAlignment = .center
                return label
            }()
        }
        
        title = text
        
        view.backgroundColor = .ypWhite
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 75
        tableView.tableHeaderView = UIView(
            frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNonzeroMagnitude)
        )
        tableView.tableFooterView = UIView(
            frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNonzeroMagnitude)
        )
        tableView.register(
            CategoryTableViewCell.self,
            forCellReuseIdentifier: CategoryTableViewCell.reuseIdentifier
        )
        
        addButton.addTarget(self, action: #selector(addTapped), for: .touchUpInside)
        
        [tableView, emptyStateView, label, dizzyImage, addButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        view.addSubview(tableView)
        view.addSubview(addButton)
        view.addSubview(emptyStateView)
        emptyStateView.addSubview(label)
        emptyStateView.addSubview(dizzyImage)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: addButton.topAnchor, constant: -24),
            
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addButton.heightAnchor.constraint(equalToConstant: 60),
            
            emptyStateView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            emptyStateView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 232),
            emptyStateView.bottomAnchor.constraint(equalTo: addButton.topAnchor, constant: 232),
            
            dizzyImage.topAnchor.constraint(equalTo: emptyStateView.topAnchor),
            dizzyImage.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            
            label.topAnchor.constraint(equalTo: dizzyImage.bottomAnchor, constant: 8),
            label.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            
        ])
    }
}

// MARK: - TableView
extension CategoryView: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfRows()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryTableViewCell",
                                                       for: indexPath
        ) as? CategoryTableViewCell
        else {
            assertionFailure("Failed to dequeue TrackerCollectionViewCell")
            return UITableViewCell()
        }
        
        let title = viewModel.titleForRow(at: indexPath.row)
        let numberOfRows = viewModel.numberOfRows()
        
        let isFirst = indexPath.row == 0
        let isLast = indexPath.row == numberOfRows - 1
        let isSingle = numberOfRows == 1
        
        cell.configure(with: title, isFirst: isFirst, isLast: isLast, isSingle: isSingle)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelectRow(at: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView,
                   contextMenuConfigurationForRowAt indexPath: IndexPath,
                   point: CGPoint) -> UIContextMenuConfiguration? {
        
        
        return UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: nil,
            actionProvider: { suggestedActions in
                
                let deleteAction = UIAction(
                    title: NSLocalizedString(Localizable.Edit.delete.localized, comment: ""),
                    attributes: .destructive
                ) { _ in
                    self.deleteTapped(index: indexPath)
                }
                
                let editAction = UIAction(
                    title: NSLocalizedString(Localizable.Edit.edit.localized, comment: ""),
                ) { _ in
                    if let cell = tableView.cellForRow(at: indexPath) as? CategoryTableViewCell {
                        let categoryTitle = cell.getCategory()
                        self.editTapped(at: indexPath, titleNow: categoryTitle)
                    }
                }
                
                return UIMenu(title: "", children: [
                    editAction,
                    deleteAction
                ])
            }
        )
    }
    
}
