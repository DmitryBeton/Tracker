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
        view.layer.masksToBounds = true
        return view
    }()
    
    private let emojiBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .white.withAlphaComponent(0.3)
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
        
        emojiLabel.text = tracker.emoji
        
        countLabel.text = dayWord(for: completedDays)
        
        updateCompletionState(isCompleted: isCompletedToday)
    }
    
    // MARK: - Private methods
    private func updateCompletionState(isCompleted: Bool) {
        if isCompleted {
            doneButton.backgroundColor = coloredView.backgroundColor?.withAlphaComponent(0.3)
            doneButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
        } else {
            doneButton.backgroundColor = coloredView.backgroundColor
            doneButton.setImage(UIImage(systemName: "plus"), for: .normal)
        }
    }
    
    private func dayWord(for countOfDays: Int) -> String {
                        
        let daysString = String.localizedStringWithFormat(
            NSLocalizedString("countOfDays", comment: "Number of completed days"),
            countOfDays
        )
        return daysString
    }
    
    // MARK: - Actions
    @objc private func didTapDoneButton() {
        guard let trackerId = trackerId else { return }
        onDoneButtonTapped?(trackerId)
    }
    
    // MARK: - SetupUI
    private func setupUI() {
        contentView.addSubview(coloredView)
        coloredView.addSubview(emojiBackgroundView)
        emojiBackgroundView.addSubview(emojiLabel)
        coloredView.addSubview(descriptionLabel)
        contentView.addSubview(countLabel)
        contentView.addSubview(doneButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Colored View
            coloredView.topAnchor.constraint(equalTo: contentView.topAnchor),
            coloredView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            coloredView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            coloredView.heightAnchor.constraint(equalToConstant: 90),
            
            // Emoji Background - фиксированный размер
            emojiBackgroundView.topAnchor.constraint(equalTo: coloredView.topAnchor, constant: 12),
            emojiBackgroundView.leadingAnchor.constraint(equalTo: coloredView.leadingAnchor, constant: 12),
            emojiBackgroundView.widthAnchor.constraint(equalToConstant: 24),
            emojiBackgroundView.heightAnchor.constraint(equalToConstant: 24),
            
            // Emoji Label - без фиксированной ширины, центрируется
            emojiLabel.centerXAnchor.constraint(equalTo: emojiBackgroundView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiBackgroundView.centerYAnchor),
            emojiLabel.heightAnchor.constraint(equalToConstant: 22),
            
            // Description Label
            descriptionLabel.leadingAnchor.constraint(equalTo: coloredView.leadingAnchor, constant: 12),
            descriptionLabel.trailingAnchor.constraint(equalTo: coloredView.trailingAnchor, constant: -12),
            descriptionLabel.bottomAnchor.constraint(equalTo: coloredView.bottomAnchor, constant: -12),
            
            // Count Label
            countLabel.topAnchor.constraint(equalTo: coloredView.bottomAnchor, constant: 16),
            countLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            countLabel.trailingAnchor.constraint(lessThanOrEqualTo: doneButton.leadingAnchor, constant: -8),
            
            // Done Button
            doneButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            doneButton.centerYAnchor.constraint(equalTo: countLabel.centerYAnchor),
            doneButton.widthAnchor.constraint(equalToConstant: 34),
            doneButton.heightAnchor.constraint(equalToConstant: 34)
        ])
    }
}
