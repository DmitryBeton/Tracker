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
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    // MARK: - Public Methods
    func setColor(_ color: UIColor) {
        view.backgroundColor = color
        layer.borderColor = color.withAlphaComponent(0.3).cgColor
    }

    func setSelected(_ isSelected: Bool) {
        layer.borderWidth = isSelected ? 3 : 0
    }

    // MARK: - Setups
    private func setupUI() {
        layer.cornerRadius = 8
        addSubview(view)
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
