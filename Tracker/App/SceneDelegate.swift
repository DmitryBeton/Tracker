//
//  SceneDelegate.swift
//  Tracker
//
//  Created by Дмитрий Чалов on 31.10.2025.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let scene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: scene)
        
        if OnboardingManager.shared.hasSeenOnboarding {
            window.rootViewController = TabBarController()
        } else {

            let onboardingVC = OnboardingViewController()
            
            onboardingVC.onShowOnboarding = { [weak self] hasSeen in
                OnboardingManager.shared.markOnboardingAsSeen()
                
                let tabBarController = TabBarController()
                
                UIView.transition(with: window,
                                  duration: 0.3,
                                  options: .transitionCrossDissolve,
                                  animations: {
                    window.rootViewController = tabBarController
                },
                                  completion: nil)
            }
            
            window.rootViewController = onboardingVC
        }
        
        self.window = window
        window.makeKeyAndVisible()
        
    }
}
