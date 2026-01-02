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
        titleText: NSLocalizedString("about_tracking", comment: "")
    )
    
    static let aboutWaterAndYoga = PageModel(
        backgroundImage: UIImage(resource: .onboardingTwo),
        titleText: NSLocalizedString("about_water_and_yoga", comment: "")
    )
}
