//
//  TrackerTests.swift
//  TrackerTests
//
//  Created by Дмитрий Чалов on 07.01.2026.
//

import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        
    }

    func testViewControllerToLightTheme() throws {
        let viewModel: TrackersViewModelProtocol = TrackersViewModelTest()
        let vc = TrackersViewController(viewModel: viewModel)
        
        assertSnapshots(matching: vc, as: [.image(traits: .init(userInterfaceStyle: .light))])

    }
    
    func testViewControllerToDarkTheme() throws {
        let viewModel: TrackersViewModelProtocol = TrackersViewModelTest()
        let vc = TrackersViewController(viewModel: viewModel)
        
        assertSnapshots(matching: vc, as: [.image(traits: .init(userInterfaceStyle: .dark))])

    }


}
