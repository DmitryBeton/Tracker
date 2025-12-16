//
//  DaysValueTransformer.swift
//  Tracker
//
//  Created by Дмитрий Чалов on 13.12.2025.
//
import Foundation
import Logging

@objc
final class DaysValueTransformer: ValueTransformer {
    private let logger = Logger(label: "DataStore")

    static func register() {
        ValueTransformer.setValueTransformer(
            DaysValueTransformer(),
            forName: NSValueTransformerName(rawValue: String(describing: DaysValueTransformer.self))
        )
    }

    override class func transformedValueClass() -> AnyClass { NSData.self }
    override class func allowsReverseTransformation() -> Bool { true }
    
    override func transformedValue(_ value: Any?) -> Any? {
        logger.info("called: \(#function) \(#line)")
        guard let days = value as? [WeekDay] else { return nil }
        return try? JSONEncoder().encode(days)
    }

    override func reverseTransformedValue(_ value: Any?) -> Any? {
        logger.info("called: \(#function) \(#line)")
        guard let data = value as? NSData else { return nil }
        return try? JSONDecoder().decode([WeekDay].self, from: data as Data)
    }
}
