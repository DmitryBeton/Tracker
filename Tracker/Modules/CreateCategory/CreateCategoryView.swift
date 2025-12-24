//
//  CategoryView.swift
//  Tracker
//
//  Created by Дмитрий Чалов on 23.12.2025.
//

import UIKit

final class CreateCategoryView: UIViewController {
    // MARK: - Properties
    private var viewModel: CategoryViewModel?
    
    private var categoryName: String = ""

    private var tableViewTopConstraint: NSLayoutConstraint?

    // MARK: - UI Elements
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название категории"
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

    private lazy var button: UIButton = {
        let button = UIButton()
        button.setTitle("Готово", for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)
        button.backgroundColor = .ypGray
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(createTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        setupUI()
        setupConstraints()
    }
    // MARK: - Actions
    @objc
    private func createTapped() {
        createCategory()
    }

    @objc private func textFieldDidChange() {
        guard let text = textField.text else { return }
        
        if text.count > 38 {
            textField.text = String(text.prefix(38))
            warningLabel.isHidden = false
            tableViewTopConstraint?.constant = 62
        } else {
            warningLabel.isHidden = true
            tableViewTopConstraint?.constant = 24
        }
        
        categoryName = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        updateCreateButtonState()
    }

    // MARK: - Public methods
    func initialize(viewModel: CategoryViewModel) {
        self.viewModel = viewModel
        bind()
    }

    // MARK: - Private methods
    private func bind() {
        guard let viewModel = viewModel else { return }
        // сделать
    }
    
    private func createCategory() {
        // TODO: - Добавляем категорию в СoreData
        dismiss(animated: true)
    }
    
    private func updateCreateButtonState() {
        let isEnabled = !categoryName.isEmpty
        button.isEnabled = isEnabled
        button.backgroundColor = isEnabled ? .ypBlack : .ypGray
    }

    private func setupUI() {
        view.addSubview(textField)
        view.addSubview(button)
        view.addSubview(warningLabel)
        
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
                label.text = "Новая категория"
                label.font = titleFont
                label.textColor = .ypBlack
                label.textAlignment = .center
                return label
            }()
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            textField.heightAnchor.constraint(equalToConstant: 75),
            textField.widthAnchor.constraint(equalToConstant: 343),
            textField.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            warningLabel.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 8),
            warningLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            warningLabel.heightAnchor.constraint(equalToConstant: 22),

            button.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            button.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
}

// MARK: - UITextFieldDelegate
extension CreateCategoryView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
