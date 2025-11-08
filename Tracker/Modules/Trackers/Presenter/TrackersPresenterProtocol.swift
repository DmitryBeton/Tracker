//
//  TrackersPresenterProtocol.swift
//  Tracker
//
//  Created by Дмитрий Чалов on 08.11.2025.
//

import Foundation

protocol TrackersPresenterProtocol {
    func viewDidLoad()
    func didSelectDate(_ date: Date)
    func didTapAddButton()
    func configureCell(_ cell: TrackerCollectionViewCell, with tracker: Tracker)
}
