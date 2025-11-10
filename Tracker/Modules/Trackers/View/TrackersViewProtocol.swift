//
//  TrackersViewProtocol.swift
//  Tracker
//
//  Created by Дмитрий Чалов on 08.11.2025.
//

import Foundation

protocol TrackersViewProtocol: AnyObject {
    func updateSingleTracker(_ trackerId: UUID, completedRecords: [TrackerRecord])
    func updateCategories(_ categories: [TrackerCategory])
    func updateCompletedRecords(_ records: [TrackerRecord])
    
    func showEmptyState()
    func hideEmptyState()
    
    func showFutureDateRestriction()
    
    func showCreateTrackerScreen()
}
