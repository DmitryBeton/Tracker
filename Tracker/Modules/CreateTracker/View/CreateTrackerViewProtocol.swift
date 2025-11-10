//
//  CreateTrackerViewProtocol.swift
//  Tracker
//
//  Created by Дмитрий Чалов on 09.11.2025.
//

protocol CreateTrackerViewProtocol: AnyObject {
    func showCategorySelection()
    func showScheduleSelection()
    func closeCreateTracker()
    func showNameRequiredError()
}

// 1. Нажать на кнопку создание трекера vc(
// 2. показать экран создания
// 3. дальнейший выбор:
    // 1. выбор категории -> заглушка
    // 2. выбор расписания -> показать экран выбора дней недели -> скрыть экран выбора
    // 3. закрыть окно
    // 4. создать трекер -> скрыть экран создания -> обновить коллекцию отображающую трекеры
