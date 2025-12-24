//
//  OnboardingViewTwo.swift
//  Tracker
//
//  Created by Дмитрий Чалов on 23.12.2025.
//

import UIKit

final class OnboardingViewTwo: UIViewController {
    private let image: UIImageView = {
        let view = UIImageView()
        let image = UIImage(resource: .onboardingTwo)
        
        view.image = image
        view.contentMode = .scaleAspectFill
        
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }

    private func setupUI() {
        view.addSubview(image)
    }
    
    private func setupConstraints() {
        image.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            image.topAnchor.constraint(equalTo: view.topAnchor),
            image.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            image.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            image.trailingAnchor.constraint(equalTo: view.trailingAnchor),


        ])
    }
}
