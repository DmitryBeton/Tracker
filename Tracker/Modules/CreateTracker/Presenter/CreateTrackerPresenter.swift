//
//  CreateTrackerPresenter.swift
//  Tracker
//
//  Created by Дмитрий Чалов on 09.11.2025.
//

import UIKit

final class CreateTrackerPresenter {
    // MARK: - Properties
    private weak var view: CreateTrackerViewProtocol?
    
    // MARK: - Lifecycle
    init(view: CreateTrackerViewProtocol) {
        self.view = view
    }
}

// MARK: - CreateTrackerPresenterProtocol
extension CreateTrackerPresenter: CreateTrackerPresenterProtocol {
    func didTapCancel() {
        
    }
    
    func didTapCreate(name: String, schedule: TrackerSchedule?) {
        
    }
    
    func didTapCategory() {
        
    }
    
    func didTapSchedule() {
        view?.showScheduleSelection()
    }
    
    
}
