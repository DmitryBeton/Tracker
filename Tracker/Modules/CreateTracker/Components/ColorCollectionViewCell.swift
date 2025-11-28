//
//  EmojiCollectionViewCell.swift
//  Tracker
//
//  Created by Дмитрий Чалов on 21.11.2025.
//

import UIKit

final class ColorCollectionViewCell: UICollectionViewCell {
    // MARK: - UI Elements
    private let view: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
    func setColor(_ color: UIColor) {
        view.backgroundColor = color
        self.layer.borderColor = color.withAlphaComponent(0.3).cgColor
    }

    func setSelected(_ isSelected: Bool) {
        if isSelected {
            self.layer.borderWidth = 3
        } else {
            self.layer.borderWidth = 0
        }
    }

    // MARK: - Setups
    private func setupUI() {
        self.layer.cornerRadius = 8
        self.addSubview(view)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 40),
            view.widthAnchor.constraint(equalToConstant: 40),
            view.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            view.centerYAnchor.constraint(equalTo: self.centerYAnchor),
        ])
    }
}
