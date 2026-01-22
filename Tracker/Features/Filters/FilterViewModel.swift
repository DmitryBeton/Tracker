//
//  FilterViewModel.swift
//  Tracker
//
//  Created by Дмитрий Чалов on 06.01.2026.
//

import UIKit

final class FilterViewModel {
    
    private var selectedFilter: Filter = .allTrackers
    
    private let dataProvider: DataProviderProtocol
    
    init(dataProvider: DataProviderProtocol) {
        self.dataProvider = dataProvider
        selectedFilter = dataProvider.getCurrentFilter()
    }
    
    let tableViewItems: [String] =
    [
        NSLocalizedString("all_trackers", comment: ""),
        NSLocalizedString("today", comment: ""),
        NSLocalizedString("completed", comment: ""),
        NSLocalizedString("not_completed", comment: ""),
    ]
    
    func numberOfFilters() -> Int {
        tableViewItems.count
    }
    
    func isSelected(at: Int) -> Bool {
        tableViewItems[at] == selectedFilter.localizedTitle
    }
    
    func selectFilter(at index: Int) {
        guard index < tableViewItems.count else { return }
        
        switch index {
        case 0:
            selectedFilter = .allTrackers
        case 1:
            selectedFilter = .todayTrackers
        case 2:
            selectedFilter = .completed
        case 3:
            selectedFilter = .notCompleted
        default:
            selectedFilter = .allTrackers
        }
    }
    
    func getFilter() -> Filter {
        selectedFilter
    }
}
