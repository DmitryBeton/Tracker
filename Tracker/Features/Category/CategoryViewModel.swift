//
//  CategoryViewModel.swift
//  Tracker
//
//  Created by Дмитрий Чалов on 23.12.2025.
//

import UIKit

protocol CategoryViewModelProtocol: AnyObject {
    // Замыкания для обновления UI
    var onDataChanged: Binding<Void>? { get set }
    var onEmptyStateChanged: Binding<Bool>? { get set }
    var onCategorySelected: Binding<String>? { get set }
    
    // Методы для работы с данными
    func loadCategories()
    func numberOfRows() -> Int
    func titleForRow(at index: Int) -> String
    func didSelectRow(at index: Int)
    func addCategory(_ name: String)
    func deleteCategory(at indexPath: IndexPath)
    func editCategory(at indexPath: IndexPath, to name: String)
}

final class CategoryViewModel: CategoryViewModelProtocol {
    
    // MARK: - Bindings
    var onDataChanged: Binding<Void>?
    var onEmptyStateChanged: Binding<Bool>?
    var onCategorySelected: Binding<String>?
    
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
        onDataChanged?(())
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
    
    func deleteCategory(at indexPath: IndexPath) {
        try? model.deleteCategory(categories[indexPath.row])
        loadCategories()
    }
    
    func editCategory(at indexPath: IndexPath, to name: String) {
        try? model.editCategory(oldName: categories[indexPath.row], newName: name)
        loadCategories()
        onCategorySelected?(categories[indexPath.row])
    }

}
