//
//  Wireframe.swift
//  Example-iOS
//
//  Created by SherlockYao on 10/27/16.
//  Copyright © 2016 SherlockYao. All rights reserved.
//

import Foundation
import SYWireframe

class Wireframe: SYWireframe {

    static let sharedWireframe: Wireframe = {
        let wireframe = Wireframe(plistName: "Wireframe")
        wireframe.registerDefaultNavigators()
        return wireframe
    }()

    func entry() -> UIViewController {
        return buildViewController(code: "Home", params: nil)
    }
}
