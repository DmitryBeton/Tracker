//
//  TrackersMockData.swift
//  Tracker
//
//  Created by Дмитрий Чалов on 09.11.2025.
//

import UIKit

enum TrackersMockData {
    static let categories: [TrackerCategory] = {
        let schedule = TrackerSchedule(selectedDays: [.monday, .tuesday, .saturday])
        
        let tracker = Tracker(name: "Полить растения", color: .ypColorSelection5, emoji: "emoji", schedule: schedule)
        
        let category1 = TrackerCategory(title: "Домашний уют", trackers: [tracker])
        
        return [category1]
    }()
}
