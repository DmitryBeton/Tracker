//
//  TabBarController.swift
//  Tracker
//
//  Created by Дмитрий Чалов on 31.10.2025.
//

import UIKit

final class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
        setupViewControllers()
    }
    
    var viewModel: TrackersViewModelProtocol?
    var statisticsViewModel: StatisticsViewModel?

    private func setupViewControllers() {
        let textTrackers = NSLocalizedString("tabbar_trackers", comment: "")
        let textStatistic = NSLocalizedString("tabbar_statistic", comment: "")
        
        guard let trackerStore = (UIApplication.shared.delegate as? AppDelegate)?.trackerStore else {
            assertionFailure("trackerStore not found")
            return
        }
        do {
            let dataProvider = try DataProvider(trackerStore)
            viewModel = TrackersViewModel(dataProvider: dataProvider)
            statisticsViewModel = StatisticsViewModel(dataProvider: dataProvider)
        } catch {
            assertionFailure("DataProvider init failed")
        }

        guard let viewModel,
            let statisticsViewModel else {
            return
        }
        
        let trackerViewController = TrackersViewController(viewModel: viewModel)
        let trackerNavigationController = UINavigationController(rootViewController: trackerViewController)
        trackerNavigationController.tabBarItem = UITabBarItem(
            title: textTrackers,
            image: UIImage(resource: .tabTracker),
            tag: 1
        )
        
        let statisticsViewController = StatisticsViewController(viewModel: statisticsViewModel)
        let statisticsNavigationController = UINavigationController(rootViewController: statisticsViewController)
        statisticsNavigationController.navigationBar.prefersLargeTitles = true
        statisticsNavigationController.tabBarItem = UITabBarItem(
            title: textStatistic,
            image: UIImage(resource: .tabStatistic),
            tag: 2
        )
        
        viewControllers = [trackerNavigationController, statisticsNavigationController]
    }
    
    private func setupTabBar() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        
        appearance.backgroundColor = .ypWhite
        
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.ypBlue]
        appearance.stackedLayoutAppearance.selected.iconColor = .ypBlue
        
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.ypGray]
        appearance.stackedLayoutAppearance.normal.iconColor = .ypGray
        
        appearance.shadowColor = .ypGray
        
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        
        tabBar.tintColor = .ypBlue
        tabBar.unselectedItemTintColor = .ypGray
    }
}
