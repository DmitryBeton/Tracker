//
//  TrackersViewProtocol.swift
//  Tracker
//
//  Created by Дмитрий Чалов on 08.11.2025.
//

protocol TrackersViewProtocol: AnyObject {
    func updateCategories(_ categories: [TrackerCategory])
    func updateCompletedRecords(_ records: [TrackerRecord])
    func showEmptyState()
    func hideEmptyState()
}
