//
//  TrackersMockData.swift
//  Tracker
//
//  Created by Дмитрий Чалов on 09.11.2025.
//

import UIKit

enum TrackersMockData {
    static let categories: [TrackerCategory] = {
        let schedule: Set<WeekDay> = [.monday, .tuesday, .sunday]
        
        let tracker = Tracker(name: "Полить растения", color: .ypColorSelection5, emoji: "😪", schedule: schedule)
        
        let category1 = TrackerCategory(title: "Домашний уют", trackers: [tracker])
        
        return [category1]
    }()
}
