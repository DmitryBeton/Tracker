//
//  CreateTrackerValidationError.swift
//  Tracker
//
//  Created by Дмитрий Чалов on 06.01.2026.
//

import UIKit

enum CreateTrackerValidationError: Error, LocalizedError {
    case nameTooLong
    case categoryNotSelected
    case scheduleNotSelected
    case emojiNotSelected
    case colorNotSelected
    
    var errorDescription: String? {
        switch self {
        case .nameTooLong:
            return NSLocalizedString("symbol_limit", comment: "")
        case .categoryNotSelected:
            return NSLocalizedString("select_category", comment: "")
        case .scheduleNotSelected:
            return NSLocalizedString("select_schedule", comment: "")
        case .emojiNotSelected:
            return NSLocalizedString("select_emoji", comment: "")
        case .colorNotSelected:
            return NSLocalizedString("select_color", comment: "")
        }
    }
}
