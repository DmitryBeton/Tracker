//
//  CreateTrackerPresenterProtocol.swift
//  Tracker
//
//  Created by Дмитрий Чалов on 09.11.2025.
//

protocol CreateTrackerPresenterProtocol: AnyObject {
    func createTracker(name: String, schedule: TrackerSchedule?) -> Tracker
    func showCategoryScreen()
}
