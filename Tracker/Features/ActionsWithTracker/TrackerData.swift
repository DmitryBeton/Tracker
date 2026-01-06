//
//  TrackerData.swift
//  Tracker
//
//  Created by Дмитрий Чалов on 06.01.2026.
//

import UIKit

struct TrackerData {
    var name: String = ""
    var category: String = ""
    var schedule: [WeekDay]?
    var emoji: String = ""
    var color: UIColor = .clear
}

struct TrackerEditedData {
    var id: UUID = UUID()
    var name: String = ""
    var category: String = ""
    var schedule: [WeekDay]?
    var emoji: String = ""
    var color: UIColor = .clear
}
