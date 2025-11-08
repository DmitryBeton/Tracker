//
//  Tracker.swift
//  Tracker
//
//  Created by Дмитрий Чалов on 03.11.2025.
//

import UIKit

struct Tracker {
    let id: UUID
    let name: String
    let color: UIColor
    let emoji: String
    let schedule: TrackerSchedule?
    
    init(id: UUID = UUID(), name: String, color: UIColor, emoji: String, schedule: TrackerSchedule? = nil) {
        self.id = id
        self.name = name
        self.color = color
        self.emoji = emoji
        self.schedule = schedule
    }
}
