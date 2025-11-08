//
//  TrackersMockData.swift
//  Tracker
//
//  Created by Дмитрий Чалов on 09.11.2025.
//

import UIKit

enum TrackersMockData {
    static let categories: [TrackerCategory] = {
        let schedule1 = TrackerSchedule(monday: true, tuesday: false, wednesday: true, thursday: false, friday: true, saturday: true, sunday: true)
        let schedule2 = TrackerSchedule(monday: false, tuesday: true, wednesday: true, thursday: true, friday: true, saturday: false, sunday: true)
        let schedule3 = TrackerSchedule(monday: true, tuesday: false, wednesday: true, thursday: true, friday: true, saturday: true, sunday: true)

        let tracker1 = Tracker(name: "Полить растения", color: .systemGreen, emoji: "🌿", schedule: schedule1)
        let tracker2 = Tracker(name: "Посадить арбузики", color: .ypRed, emoji: "🍉", schedule: schedule2)
        let tracker3 = Tracker(name: "Скушать додстер", color: .ypBlue, emoji: "🌯", schedule: schedule3)

        let category1 = TrackerCategory(title: "Домашний уют", trackers: [tracker1, tracker2])
        let category2 = TrackerCategory(title: "Моё питание", trackers: [tracker3])

        return [category1, category2]
    }()
}
