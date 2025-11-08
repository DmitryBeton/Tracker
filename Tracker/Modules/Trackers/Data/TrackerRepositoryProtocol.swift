//
//  TrackerRepositoryProtocol.swift
//  Tracker
//
//  Created by Дмитрий Чалов on 08.11.2025.
//

import Foundation

protocol TrackerRepositoryProtocol {
    func fetchCategories() -> [TrackerCategory]
    func filteredCategories(for date: Date, from categories: [TrackerCategory]) -> [TrackerCategory]
}
