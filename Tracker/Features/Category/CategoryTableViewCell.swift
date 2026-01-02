//
//  CategoryTableViewCell.swift
//  Tracker
//
//  Created by Дмитрий Чалов on 27.12.2025.
//

import UIKit

final class CategoryTableViewCell: UITableViewCell {
    
    // MARK: - Static Properties
    static let reuseIdentifier = "CategoryTableViewCell"
    
    // MARK: - UI Elements
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    func configure(with title: String, isFirst: Bool = false, isLast: Bool = false, isSingle: Bool = false) {
        titleLabel.text = title
        configureCorners(isFirst: isFirst, isLast: isLast, isSingle: isSingle)
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        backgroundColor = .ypBackground
        selectionStyle = .none
        layer.masksToBounds = true
        
        contentView.addSubview(titleLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }
    
    private func configureCorners(isFirst: Bool, isLast: Bool, isSingle: Bool) {
        if isSingle {
            layer.cornerRadius = 16
            layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner,
                                   .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else if isFirst {
            layer.cornerRadius = 16
            layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else if isLast {
            layer.cornerRadius = 16
            layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else {
            layer.cornerRadius = 0
        }
    }
}
