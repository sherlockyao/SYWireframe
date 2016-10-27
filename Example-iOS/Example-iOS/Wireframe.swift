//
//  Wireframe.swift
//  Example-iOS
//
//  Created by SherlockYao on 10/27/16.
//  Copyright © 2016 SherlockYao. All rights reserved.
//

import Foundation
import SYWireframe

enum WireframePort: String {
    case home = "Home"
    case detail = "Detail"
}

enum WireframeGate: String {
    case seller = "Seller"
    case product = "Product"
}

class Wireframe: SYWireframe {

    static let sharedWireframe: Wireframe = {
        let wireframe = Wireframe(plistName: "Wireframe")
        wireframe.registerDefaultNavigators()
        wireframe.registerBuilders()
        return wireframe
    }()

    func entry() -> UIViewController {
        return buildViewController(code: WireframePort.home.rawValue, params: nil)
    }
    
    /// util method so wireframe can use enum value for "port" and "gate"
    func navigateTo(port: WireframePort, gate: WireframeGate?, params: Dictionary<String, Any>?, from sourceViewController: UIViewController, completion: SYWireframeCompletionHandler?) {
        navigateTo(port: port.rawValue, gate: gate?.rawValue, params: params, from: sourceViewController, completion: completion)
    }
    
    private func registerBuilders() {
        
    }
}
