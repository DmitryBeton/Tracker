//
//  PageModel.swift
//  Tracker
//
//  Created by Дмитрий Чалов on 26.12.2025.
//

import UIKit

struct PageModel {
    let backgroundImage: UIImage
    let titleText: String
}

extension PageModel {
    static let aboutTracking = PageModel(
        backgroundImage: UIImage(resource: .onboardingOne),
        titleText: "Отслеживайте только то, что хотите"
    )
    
    static let aboutWaterAndYoga = PageModel(
        backgroundImage: UIImage(resource: .onboardingTwo),
        titleText: "Даже если это не литры воды и йога"
    )
}
