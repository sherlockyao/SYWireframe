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
    case back = "Back"
    case detail = "Detail"
}

enum WireframeGate: String {
    case seller = "Seller"
    case product = "Product"
}

enum WireframeParam: String {
    case name = "name"
}

class Wireframe: SYWireframe {

    static let sharedWireframe: Wireframe = {
        let wireframe = Wireframe(plistName: "Wireframe")
        wireframe.registerBuilders()
        wireframe.registerNavigators()
        wireframe.transition = WireframeTransition()
        return wireframe
    }()

    /// util method so wireframe can use enum value for "port" and "gate"
    func navigateTo(port: WireframePort, gate: WireframeGate? = nil, params: Dictionary<String, Any>? = nil, from sourceViewController: UIViewController, completion: SYWireframeCompletionHandler? = nil) {
        navigateTo(port: port.rawValue, gate: gate?.rawValue, params: params, from: sourceViewController, completion: completion)
    }
    
    func entry() -> UIViewController {
        return buildViewController(code: WireframePort.home.rawValue, params: nil)
    }
    
    // MARK: - registration for app's use cases
    
    private func registerBuilders() {
        register(builderName: "seller") { (params) -> UIViewController in
            return SellerViewController(nibName: "SellerViewController", bundle: nil)
        }
        
        register(builderName: "product") { (params) -> UIViewController in
            let productViewController = ProductViewController()
            productViewController.productName = params?[WireframeParam.name.rawValue] as? String
            return productViewController;
        }
    }
    
    private func registerNavigators() {
        registerDefaultNavigators()
        
        register(navigatorName: "navigation-wrap") { (sourceViewController, destinationViewController, completion) in
            let navigationController = UINavigationController(rootViewController: destinationViewController)
            sourceViewController.present(navigationController, animated: false, completion: completion)
        }
    }
}
