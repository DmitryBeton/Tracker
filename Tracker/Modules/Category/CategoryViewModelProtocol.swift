//
//  CategoryViewModelProtocol.swift
//  Tracker
//
//  Created by Дмитрий Чалов on 27.12.2025.
//

import Foundation

protocol CategoryViewModelProtocol: AnyObject {
    // Замыкания для обновления UI
    var onDataChanged: (() -> Void)? { get set }
    var onEmptyStateChanged: ((Bool) -> Void)? { get set }
    var onCategorySelected: ((String) -> Void)? { get set }
    
    // Методы для работы с данными
    func loadCategories()
    func numberOfRows() -> Int
    func titleForRow(at index: Int) -> String
    func didSelectRow(at index: Int)
    func addCategory(_ name: String)
}
