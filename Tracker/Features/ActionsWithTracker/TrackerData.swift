//
//  TrackerData.swift
//  Tracker
//
//  Created by Дмитрий Чалов on 06.01.2026.
//

import UIKit

struct TrackerData {
    let name: String
    let category: String
    let schedule: [WeekDay]?
    let emoji: String
    let color: UIColor

    init(
        name: String = "",
        category: String = "",
        schedule: [WeekDay]? = nil,
        emoji: String = "",
        color: UIColor = .clear
    ) {
        self.name = name
        self.category = category
        self.schedule = schedule
        self.emoji = emoji
        self.color = color
    }

    func withName(_ name: String) -> TrackerData {
        TrackerData(
            name: name,
            category: self.category,
            schedule: self.schedule,
            emoji: self.emoji,
            color: self.color
        )
    }

    func withCategory(_ category: String) -> TrackerData {
        TrackerData(
            name: self.name,
            category: category,
            schedule: self.schedule,
            emoji: self.emoji,
            color: self.color
        )
    }

    func withSchedule(_ schedule: [WeekDay]?) -> TrackerData {
        TrackerData(
            name: self.name,
            category: self.category,
            schedule: schedule,
            emoji: self.emoji,
            color: self.color
        )
    }

    func withEmoji(_ emoji: String) -> TrackerData {
        TrackerData(
            name: self.name,
            category: self.category,
            schedule: self.schedule,
            emoji: emoji,
            color: self.color
        )
    }

    func withColor(_ color: UIColor) -> TrackerData {
        TrackerData(
            name: self.name,
            category: self.category,
            schedule: self.schedule,
            emoji: self.emoji,
            color: color
        )
    }
}

struct TrackerEditedData {
    let id: UUID
    let name: String
    let category: String
    let schedule: [WeekDay]?
    let emoji: String
    let color: UIColor

    init(
        id: UUID = UUID(),
        name: String = "",
        category: String = "",
        schedule: [WeekDay]? = nil,
        emoji: String = "",
        color: UIColor = .clear
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.schedule = schedule
        self.emoji = emoji
        self.color = color
    }

    func withID(_ id: UUID) -> TrackerEditedData {
        TrackerEditedData(
            id: id,
            name: self.name,
            category: self.category,
            schedule: self.schedule,
            emoji: self.emoji,
            color: self.color
        )
    }

    func withName(_ name: String) -> TrackerEditedData {
        TrackerEditedData(
            id: self.id,
            name: name,
            category: self.category,
            schedule: self.schedule,
            emoji: self.emoji,
            color: self.color
        )
    }

    func withCategory(_ category: String) -> TrackerEditedData {
        TrackerEditedData(
            id: self.id,
            name: self.name,
            category: category,
            schedule: self.schedule,
            emoji: self.emoji,
            color: self.color
        )
    }

    func withSchedule(_ schedule: [WeekDay]?) -> TrackerEditedData {
        TrackerEditedData(
            id: self.id,
            name: self.name,
            category: self.category,
            schedule: schedule,
            emoji: self.emoji,
            color: self.color
        )
    }

    func withEmoji(_ emoji: String) -> TrackerEditedData {
        TrackerEditedData(
            id: self.id,
            name: self.name,
            category: self.category,
            schedule: self.schedule,
            emoji: emoji,
            color: self.color
        )
    }

    func withColor(_ color: UIColor) -> TrackerEditedData {
        TrackerEditedData(
            id: self.id,
            name: self.name,
            category: self.category,
            schedule: self.schedule,
            emoji: self.emoji,
            color: color
        )
    }
}
