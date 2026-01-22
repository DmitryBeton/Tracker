//
//  Filter.swift
//  Tracker
//
//  Created by Дмитрий Чалов on 06.01.2026.
//

import Foundation

enum Filter: String {
    case allTrackers = "all_trackers"
    case todayTrackers = "today"
    case completed = "completed"
    case notCompleted = "not_completed"
    
    var localizedTitle: String {
        return NSLocalizedString(self.rawValue, comment: "")
    }
}
