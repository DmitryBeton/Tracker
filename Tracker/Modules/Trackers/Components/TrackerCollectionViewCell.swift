//
//  TrackerCollectionViewCell.swift
//  Tracker
//
//  Created by Дмитрий Чалов on 05.11.2025.
//

import UIKit

final class TrackerCollectionViewCell: UICollectionViewCell {
    // MARK: - Properties
    private var trackerId: UUID?
    var onDoneButtonTapped: ((UUID) -> Void)?
    
    // MARK: - UI Elements
    private let coloredView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        return view
    }()
    
    private let emojiImage: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypWhite
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let countLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = .ypWhite
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapDoneButton), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    func configure(with tracker: Tracker, completedDays: Int = 0, isCompletedToday: Bool) {
        trackerId = tracker.id
        
        descriptionLabel.text = tracker.name
        
        coloredView.backgroundColor = tracker.color
        doneButton.backgroundColor = tracker.color
        
        emojiImage.image = UIImage(named: tracker.emoji)
        
        countLabel.text = "\(completedDays) \(dayWord(for: completedDays))"
        
        updateCompletionState(isCompleted: isCompletedToday)
    }
    
    // MARK: - Private methods
    // Обновляет состояние кнопки выполнения трекера
    private func updateCompletionState(isCompleted: Bool) {
        if isCompleted {
            doneButton.backgroundColor = coloredView.backgroundColor?.withAlphaComponent(0.3)
            doneButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
            
        } else {
            doneButton.backgroundColor = coloredView.backgroundColor
            doneButton.setImage(UIImage(systemName: "plus"), for: .normal)
        }
    }
    
    // Правильно склоняет слово "день"
    private func dayWord(for count: Int) -> String {
        let n = abs(count) % 100
        if n >= 11 && n <= 19 {
            return "дней"
        }
        switch n % 10 {
        case 1: return "день"
        case 2, 3, 4: return "дня"
        default: return "дней"
        }
    }
    
    // MARK: - Actions
    @objc // Отмечает выполнение трекера
    private func didTapDoneButton() {
        guard let trackerId = trackerId else { return }
        onDoneButtonTapped?(trackerId)
    }
    
    // MARK: - SetupUI
    private func setupUI() {
        self.addSubview(coloredView)
        coloredView.addSubview(emojiImage)
        coloredView.addSubview(descriptionLabel)
        self.addSubview(countLabel)
        self.addSubview(doneButton)
        
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            coloredView.topAnchor.constraint(equalTo: self.topAnchor),
            coloredView.leftAnchor.constraint(equalTo: self.leftAnchor),
            coloredView.widthAnchor.constraint(equalToConstant: 167),
            coloredView.heightAnchor.constraint(equalToConstant: 90),
            
            emojiImage.topAnchor.constraint(equalTo: coloredView.topAnchor, constant: 12),
            emojiImage.leftAnchor.constraint(equalTo: coloredView.leftAnchor, constant: 12),
            emojiImage.widthAnchor.constraint(equalToConstant: 24),
            emojiImage.heightAnchor.constraint(equalToConstant: 24),
            
            descriptionLabel.bottomAnchor.constraint(equalTo: coloredView.bottomAnchor, constant: -12),
            descriptionLabel.leftAnchor.constraint(equalTo: coloredView.leftAnchor, constant: 12),
            descriptionLabel.rightAnchor.constraint(equalTo: coloredView.rightAnchor, constant: -12),
            
            countLabel.topAnchor.constraint(equalTo: coloredView.bottomAnchor, constant: 16),
            countLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 12),
            
            doneButton.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -12),
            doneButton.topAnchor.constraint(equalTo: coloredView.bottomAnchor, constant: 8),
            doneButton.widthAnchor.constraint(equalToConstant: 34),
            doneButton.heightAnchor.constraint(equalToConstant: 34)
            
        ])
    }
    
}
