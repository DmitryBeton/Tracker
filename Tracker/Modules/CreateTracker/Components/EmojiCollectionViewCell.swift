//
//  EmojiCollectionViewCell.swift
//  Tracker
//
//  Created by Дмитрий Чалов on 21.11.2025.
//

import UIKit

final class EmojiCollectionViewCell: UICollectionViewCell {
    // MARK: - UI Elements
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .ypWhite
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
    func setEmoji(_ emoji: String) {
        emojiLabel.text = emoji
    }

    func setSelected(_ isSelected: Bool) {
        if isSelected {
            self.backgroundColor = .ypLightGray
        } else {
            self.backgroundColor = .clear
        }
    }

    // MARK: - Setups
    private func setupUI() {
        self.layer.cornerRadius = 16
        self.addSubview(emojiLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
        ])
    }
}
