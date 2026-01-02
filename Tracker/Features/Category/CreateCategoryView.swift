//
//  CategoryView.swift
//  Tracker
//
//  Created by Дмитрий Чалов on 23.12.2025.
//

import UIKit

final class CreateCategoryView: UIViewController {
    
    // MARK: - Properties
    private let viewModel: CreateCategoryViewModel
    var onCreateCategory: ((String) -> Void)?
    
    // MARK: - UI
    private lazy var textField: UITextField = {
        let textField = UITextField()
        let text = NSLocalizedString("enter_name_of_category", comment: "")
        textField.placeholder = text
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = .ypBackground
        textField.layer.cornerRadius = 16
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftViewMode = .always
        textField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        textField.returnKeyType = .done
        textField.delegate = self
        textField.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        textField.enablesReturnKeyAutomatically = true
        textField.clearButtonMode = .whileEditing
        return textField
    }()
    
    private lazy var button: UIButton = {
        let button = UIButton()
        let text = NSLocalizedString("ready", comment: "")
        button.setTitle(text, for: .normal)
        button.layer.cornerRadius = 16
        button.isEnabled = false
        button.backgroundColor = .ypGray
        button.setTitleColor(.ypWhite, for: .normal)
        button.addTarget(self, action: #selector(createTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Init
    init(viewModel: CreateCategoryViewModel) {
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
        setupKeyboardDismiss()
    }
    
    // MARK: - Bind
    private func bind() {
        viewModel.onButtonStateChanged = { [weak self] isEnabled in
            self?.button.isEnabled = isEnabled
            self?.button.backgroundColor = isEnabled ? .ypBlack : .ypGray
        }
    }
    
    // MARK: - Keyboard dismiss
    private func setupKeyboardDismiss() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        textField.returnKeyType = .done
        textField.delegate = self
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Actions
    @objc private func textChanged() {
        viewModel.updateName(textField.text ?? "")
    }
    
    @objc private func createTapped() {
        onCreateCategory?(viewModel.name)
        dismiss(animated: true)
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        let text = NSLocalizedString("new_category", comment: "")
        title = text
        
        view.backgroundColor = .ypWhite
        
        view.addSubview(textField)
        view.addSubview(button)
        
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textField.heightAnchor.constraint(equalToConstant: 75),
            
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            button.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}

// MARK: - UITextFieldDelegate
extension CreateCategoryView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismissKeyboard()
        return true
    }
}
