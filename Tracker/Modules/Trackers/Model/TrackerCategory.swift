//
//  TrackerCategory.swift
//  Tracker
//
//  Created by Дмитрий Чалов on 03.11.2025.
//

struct TrackerCategory {
    let title: String
    let trackers: [Tracker]
    
    init(title: String, trackers: [Tracker]) {
        self.title = title
        self.trackers = trackers
    }
}
