//
//  AppDelegate.swift
//  Tracker
//
//  Created by Дмитрий Чалов on 31.10.2025.
//

import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    
    lazy var trackerDataStore: TrackerDataStore = {
        do {
            print("💿DataStore получен")
            return try DataStore()
        } catch {
            print("❌ERROR: не удалось получить DataStore")
            return NullStore()
        }
    }()

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        DaysValueTransformer.register()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let configuration = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        configuration.storyboard = nil
        configuration.sceneClass = UIWindowScene.self
        configuration.delegateClass = SceneDelegate.self
        return configuration
    }
}
