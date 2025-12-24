//
//  CategoryModel.swift
//  Tracker
//
//  Created by Дмитрий Чалов on 23.12.2025.
//

import Foundation

protocol CategoryModelProtocol {
    func fetchCategories() -> [String]
    func addCategory(_ name: String) throws
}

final class CategoryModel: CategoryModelProtocol {

    private let dataProvider: DataProviderProtocol

    init(dataProvider: DataProviderProtocol) {
        self.dataProvider = dataProvider
    }

    func fetchCategories() -> [String] {
        dataProvider.fetchAllCategories()
    }

    func addCategory(_ name: String) throws {
        try dataProvider.addCategory(name)
    }
}
