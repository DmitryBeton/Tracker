//
//  Localizable.swift
//  Tracker
//
//  Created by Дмитрий Чалов on 11.01.2026.
//

import Foundation

enum Localizable {
    enum WeekDay {
        enum monday {
            static let full = "monday_full"
            static let short = "monday_short"
        }
        enum tuesday {
            static let full = "tuesday_full"
            static let short = "tuesday_short"
        }
        enum wednesday {
            static let full = "wednesday_full"
            static let short = "wednesday_short"
        }
        enum thursday {
            static let full = "thursday_full"
            static let short = "thursday_short"
        }
        enum friday {
            static let full = "friday_full"
            static let short = "friday_short"
        }
        enum saturday {
            static let full = "saturday_full"
            static let short = "saturday_short"
        }
        enum sunday {
            static let full = "sunday_full"
            static let short = "sunday_short"
        }
    }
}

extension String {
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
}

