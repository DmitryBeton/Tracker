//
//  StatisticsTableViewCell.swift
//  Tracker
//
//  Created by Дмитрий Чалов on 07.01.2026.
//

import UIKit

final class StatisticsTableViewCell: UITableViewCell {
    // MARK: - Static Properties
    static let reuseIdentifier = "StatisticTableViewCell"

    // MARK: - UI Elements
    private lazy var numberLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "0"
        label.font = .systemFont(ofSize: 34, weight: .bold)
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = NSLocalizedString("description", comment: "")
        label.font = .systemFont(ofSize: 12, weight: .regular)
        return label
    }()
    
    // MARK: - Gradient Border
    private let gradientBorderLayer = CAGradientLayer()
    private let borderShapeLayer = CAShapeLayer()

    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
        setupGradientBorder()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        updateGradientBorderFrame()
    }

    // MARK: - Setup
    private func setupUI() {
        self.addSubview(numberLabel)
        self.addSubview(descriptionLabel)
        self.backgroundColor = .clear
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            numberLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 12),
            numberLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 12),
            
            descriptionLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 12),
            descriptionLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -12),
        ])
    }
    
    // MARK: - Gradient Border Setup
    private func setupGradientBorder() {
        gradientBorderLayer.colors = [
            UIColor(red: 0/255, green: 123/255, blue: 250/255, alpha: 1).cgColor,
            UIColor(red: 70/255, green: 230/255, blue: 157/255, alpha: 1).cgColor,
            UIColor(red: 253/255, green: 76/255, blue: 73/255, alpha: 1).cgColor
        ]

        gradientBorderLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientBorderLayer.endPoint   = CGPoint(x: 1, y: 0.5)

        borderShapeLayer.fillColor = UIColor.clear.cgColor
        borderShapeLayer.strokeColor = UIColor.black.cgColor
        borderShapeLayer.lineWidth = 1

        gradientBorderLayer.mask = borderShapeLayer
        contentView.layer.addSublayer(gradientBorderLayer)
    }

    private func updateGradientBorderFrame() {
        gradientBorderLayer.frame = contentView.bounds

        let cornerRadius: CGFloat = 16
        let path = UIBezierPath(
            roundedRect: contentView.bounds.insetBy(dx: 0.5, dy: 0.5),
            cornerRadius: cornerRadius
        )

        borderShapeLayer.path = path.cgPath
        borderShapeLayer.frame = contentView.bounds
    }
    
    // MARK: - Public Methods
    func configuration(count: String, text: String) {
        self.numberLabel.text = count
        self.descriptionLabel.text = text
    }
}
