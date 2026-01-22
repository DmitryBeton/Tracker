//
//  OnboardingManager.swift
//  Tracker
//
//  Created by Дмитрий Чалов on 24.12.2025.
//

import Foundation

final class OnboardingManager {
    static let shared = OnboardingManager()
    
    private let userDefaults = UserDefaults.standard
    private let hasSeenOnboardingKey = "hasSeenOnboarding"
    
    var hasSeenOnboarding: Bool {
        get {
            return userDefaults.bool(forKey: hasSeenOnboardingKey)
        }
        set {
            userDefaults.set(newValue, forKey: hasSeenOnboardingKey)
        }
    }
    
    private init() {}
    
    func markOnboardingAsSeen() {
        hasSeenOnboarding = true
    }
    
    func resetOnboarding() {
        hasSeenOnboarding = false
    }
}
