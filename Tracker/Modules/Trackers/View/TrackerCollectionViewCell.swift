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
    private var cellColor: UIColor = .ypWhite
    var onDoneButtonTapped: ((UUID) -> Void)?
    
    // MARK: - UI Elements
    private let coloredView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
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
    
    private let doneButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = .ypWhite
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(nil, action: #selector(didTapDoneButton), for: .touchUpInside)
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
        cellColor = tracker.color
        descriptionLabel.text = tracker.name
        coloredView.backgroundColor = cellColor
        doneButton.backgroundColor = cellColor
        
        emojiImage.image = UIImage(named: tracker.emoji)
        countLabel.text = "\(completedDays) дней"
        
        coloredView.layer.cornerRadius = 16
        
        updateCompletionState(isCompleted: isCompletedToday)
    }
    
    func updateCompletionState(isCompleted: Bool) {
        if isCompleted {
            // Выполнено: кнопка полупрозрачная с галочкой
            doneButton.backgroundColor = cellColor.withAlphaComponent(0.3)
            doneButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
            doneButton.tintColor = cellColor // Цвет иконки совпадает с цветом трекера
        } else {
            // Не выполнено: кнопка непрозрачная с плюсом
            doneButton.backgroundColor = cellColor
            doneButton.setImage(UIImage(systemName: "plus"), for: .normal)
            doneButton.tintColor = .white // Белая иконка на цветном фоне
        }
    }

    // MARK: - Actions
    @objc
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
