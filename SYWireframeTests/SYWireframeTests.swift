//
//  SYWireframeTests.swift
//  SYWireframeTests
//
//  Created by SherlockYao on 10/24/16.
//  Copyright © 2016 SherlockYao. All rights reserved.
//

import XCTest
@testable import SYWireframe

class SYHomeViewController: UIViewController {
    var executedFlag = false
    
    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        executedFlag = true
    }
}

class SYWireframeTests: XCTestCase {
    
    var wireframe: SYWireframe?
    
    override func setUp() {
        super.setUp()
        
        wireframe = SYWireframe(plistFileName: "SYWireframe-Sample")
        
        wireframe?.register(builderName: "list") { (params) -> UIViewController in
            return UIViewController()
        }
        
        wireframe?.registerDefaultNavigators()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testInitialization() {
        XCTAssertNotNil(wireframe)
    }
    
    func testNavigateToPort() {
        let viewController = SYHomeViewController()
        
        wireframe?.navigateTo(port: "List", gate: "Products", from: viewController)
        
        XCTAssertTrue(viewController.executedFlag)
    }
}
