//
//  SYWireframeTransitionComponent.swift
//  SYWireframe
//
//  Created by SherlockYao on 10/24/16.
//  Copyright © 2016 SherlockYao. All rights reserved.
//

import UIKit

public typealias SYWireframeCompletionHandler = () -> Void

// MARK: Protocols

public protocol SYWireframeBuilder {
    
    func buildViewController(params: Dictionary<String, Any>?) -> UIViewController
}

public protocol SYWireframeNavigator {
    
    func navigate(from soureViewController: UIViewController, to destinationViewController: UIViewController, completion: SYWireframeCompletionHandler?)
}

public protocol SYWireframeTransition {
    
    func setupTransition(from soureViewController: UIViewController, to destinationViewController: UIViewController)
    
    func setupTransition(for navigationController: UINavigationController)
    
}

// MARK: Default Builders

struct SYAlertControllerBuilder: SYWireframeBuilder {
    
    public func buildViewController(params: Dictionary<String, Any>?) -> UIViewController {
        guard let params = params else {
            return UIAlertController()
        }
        
        let alertController = UIAlertController(title: params["title"] as? String, message: params["message"] as? String, preferredStyle: .alert)
        
        if let actions = params["actions"] as? [UIAlertAction] {
            for action in actions {
                alertController.addAction(action)
            }
        }
        
        if let color = params["color"] as? UIColor {
            alertController.view.tintColor = color
        }
        
        return alertController
    }
    
}

struct SYClosureWrapBuilder: SYWireframeBuilder {
    
    let closure: (Dictionary<String, Any>?) -> UIViewController
    
    public func buildViewController(params: Dictionary<String, Any>?) -> UIViewController {
        return closure(params)
    }
}

// MARK: Default Navigators

enum SYNavigatorType {
    case animatedPresent, instantPresent
    case animatedDismiss, instantDismiss
    case animatedPush, animatedPop, animatedPopRoot
}

struct SYBasicNavigator: SYWireframeNavigator {
    
    let type: SYNavigatorType
    
    public func navigate(from soureViewController: UIViewController, to destinationViewController: UIViewController, completion: SYWireframeCompletionHandler?) {
        switch type {
        case .animatedPresent:
            soureViewController.present(destinationViewController, animated: true, completion: completion)
        case .instantPresent:
            soureViewController.present(destinationViewController, animated: false, completion: completion)
        case .animatedDismiss:
            soureViewController.dismiss(animated: true, completion: completion)
        case .instantDismiss:
            soureViewController.dismiss(animated: false, completion: completion)
        case .animatedPush:
            soureViewController.navigationController?.pushViewController(destinationViewController, animated: true)
            completion?()
        case .animatedPop:
            _ = soureViewController.navigationController?.popViewController(animated: true)
            completion?()
        case .animatedPopRoot:
            _ = soureViewController.navigationController?.popToRootViewController(animated: true)
            completion?()
        }
    }
}

struct SYClosureWrapNavigator: SYWireframeNavigator {

    let closure: (UIViewController, UIViewController, SYWireframeCompletionHandler?) -> Void
    
    public func navigate(from soureViewController: UIViewController, to destinationViewController: UIViewController, completion: SYWireframeCompletionHandler?) {
        closure(soureViewController, destinationViewController, completion)
    }

}
