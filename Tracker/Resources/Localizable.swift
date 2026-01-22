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
    
    enum Onboarding {
        static let technologies = "technologies"
        static let aboutTracking = "about_tracking"
        static let aboutWaterAndYoga = "about_water_and_yoga"
    }
    
    enum Statistics {
        static let noDataForAnalysis = "no_data_for_analysis"
        static let statistics = "statistics"
        static let description = "description"
        static let bestPeriod = "best_period"
        static let idealDays = "ideal_days"
        static let trackersCompleted = "trackers_completed"
        static let averageValue = "average_value"
    }
    
    enum Filters {
        static let allTrackers = "all_trackers"
        static let today = "today"
        static let completed = "completed"
        static let notCompleted = "not_completed"
        static let titleFilters = "title_filters"
        static let notFound = "not_found"
        static let unavailable = "unavailable"
    }
    
    enum Edit {
        static let editCategory = "edit_category"
        static let editTracker = "edit_tracker"
        static let save = "save"
        static let pin = "pin"
        static let edit = "edit"
        static let delete = "delete"
        static let wannaDeleteTracker = "wanna_delete_tracker"
        static let deleteCategory = "delete_category"
    }
    
    enum Other {
        static let whatWeWillBeTracking = "what_we_will_be_tracking"
        static let canBeCombinedIntoCategories = "can_be_combined_into_categories"
        static let tabbarTrackers = "tabbar_trackers"
        static let titleTrackers = "title_trackers"
        static let tabbarStatistic = "tabbar_statistic"
        static let newTracker = "new_tracker"
        static let newCategory = "new_category"
        static let enterNameOfTracker = "enter_name_of_tracker"
        static let enterNameOfCategory = "enter_name_of_category"
        static let category = "category"
        static let schedule = "schedule"
        static let emoji = "emoji"
        static let color = "color"
        static let cancel = "cancel"
        static let create = "create"
        static let ready = "ready"
        static let addCategory = "add_category"
        static let search = "search"
        static let symbolLimit = "symbol_limit"
        static let everyDay = "every_day"
        static let futureDateWarning = "future_date_warning"
    }
}

extension String {
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
}

