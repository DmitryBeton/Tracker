//
//  CategoryViewModel.swift
//  Tracker
//
//  Created by Дмитрий Чалов on 23.12.2025.
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

final class CategoryViewModel: CategoryViewModelProtocol {
    
    // MARK: - Bindings
    var onDataChanged: (() -> Void)?
    var onEmptyStateChanged: ((Bool) -> Void)?
    var onCategorySelected: ((String) -> Void)?
    
    // MARK: - Private
    private let model: CategoryModelProtocol
    private var categories: [String] = []
    
    // MARK: - Init
    init(model: CategoryModelProtocol) {
        self.model = model
    }
    
    // MARK: - Public API
    func loadCategories() {
        categories = model.fetchCategories()
        onEmptyStateChanged?(categories.isEmpty)
        onDataChanged?()
    }
    
    func numberOfRows() -> Int {
        categories.count
    }
    
    func titleForRow(at index: Int) -> String {
        categories[index]
    }
    
    func didSelectRow(at index: Int) {
        onCategorySelected?(categories[index])
    }
    
    func addCategory(_ name: String) {
        try? model.addCategory(name)
        loadCategories()
    }
}
