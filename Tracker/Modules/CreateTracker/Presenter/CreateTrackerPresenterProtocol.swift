//
//  CreateTrackerPresenterProtocol.swift
//  Tracker
//
//  Created by Дмитрий Чалов on 09.11.2025.
//

protocol CreateTrackerPresenterProtocol {
    func didTapCancel()
    func didTapCreate(name: String, schedule: TrackerSchedule?)
    func didTapCategory()
    func didTapSchedule()
}

