//
//  CategoryViewModel.swift
//  Tracker
//
//  Created by Дмитрий Чалов on 23.12.2025.
//

import Foundation

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
