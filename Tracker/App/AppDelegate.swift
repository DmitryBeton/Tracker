//
//  AppDelegate.swift
//  Tracker
//
//  Created by Дмитрий Чалов on 31.10.2025.
//

import UIKit
import Logging

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    private let logger = Logger(label: "AppDelegate")

    lazy var trackerDataStore: TrackerDataStore = {
        do {
            logger.info("✅ DataStore получен - \(#function)")
            return try DataStore()
        } catch {
            logger.error("❌ не удалось получить DataStore - \(#function)")
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
