//
//  CreateTrackerViewProtocol.swift
//  Tracker
//
//  Created by Дмитрий Чалов on 09.11.2025.
//

protocol CreateTrackerViewProtocol: AnyObject {
    func showCategorySelection() // Заглушка - использовать категорию с фикс названием
    func showScheduleSelection() // ScheduleViewController
    func closeCreateTracker()
}
