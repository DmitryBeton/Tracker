//
//  CategoryViewModel.swift
//  Tracker
//
//  Created by Дмитрий Чалов on 23.12.2025.
//

import Foundation

final class EditCategoryViewModel {
    
    var onButtonStateChanged: Binding<Bool>?
    
    private(set) var name: String = "" {
        didSet {
            onButtonStateChanged?(!name.isEmpty)
        }
    }
    
    func updateName(_ text: String) {
        name = text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

