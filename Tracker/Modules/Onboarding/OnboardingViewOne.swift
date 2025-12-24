//
//  OnboardingViewOne.swift
//  Tracker
//
//  Created by Дмитрий Чалов on 23.12.2025.
//

import UIKit

final class OnboardingViewOne: UIViewController {
    private let image: UIImageView = {
        let view = UIImageView()
        let image = UIImage(resource: .onboardingOne)
        
        view.image = image
        view.contentMode = .scaleAspectFill
        
        return view
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.text = "Отслеживайте только то, что хотите"
        
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .ypBlack

        label.numberOfLines = 0
        label.textAlignment = .center
        
        return label
    }()
    
    private lazy var button: UIButton = {
        let button = UIButton()
        
        button.setTitle("Вот это технологии!", for: .normal)
        button.setTitleColor(UIColor.ypWhite, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.titleLabel?.textAlignment = .center
        
        button.backgroundColor = .ypBlack
        button.layer.cornerRadius = 16
        
        button.addTarget(self, action: #selector(openTracker), for: .touchUpInside)
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }
    
    @objc
    private func openTracker() {
        let tabBarController = TabBarController()
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }
        
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
            window.rootViewController = tabBarController
        }, completion: nil)
    }
    
    private func setupUI() {
        view.addSubview(image)
        view.addSubview(button)
        view.addSubview(label)
    }
    
    private func setupConstraints() {
        image.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            image.topAnchor.constraint(equalTo: view.topAnchor),
            image.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            image.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            image.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            button.heightAnchor.constraint(equalToConstant: 60),
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            button.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),

            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            label.bottomAnchor.constraint(equalTo: button.topAnchor, constant: -160),


        ])
    }
}
