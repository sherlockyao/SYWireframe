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

/**
 Builder takes responsibility for initializing/creating view controllers
 Parameters contains all infomation it needed to init the view controller
 
 When you put "builder" key at Decodes section of the configuration .plist file
 The wireframe will find the builder with the same name registered in it,
 then call the protocol method method to create view controller instance
 */
public protocol SYWireframeBuilder {
    
    func buildViewController(params: Dictionary<String, Any>?) -> UIViewController
}

/**
 Navigator takes responsibility for performing the navigation/jumping between two view controllers,
 Basically it will check what type is both view controllers, and choose the navigation behavior based on current App's design
 
 When you put "navigator" key at Destinations section of the configuration .plist file
 The wireframe will find the navigator with the same name registered in it,
 after it creating the destination view controller, it will call the protocol method to perform the navigation
 */
public protocol SYWireframeNavigator {
    
    func navigate(from soureViewController: UIViewController, to destinationViewController: UIViewController, completion: SYWireframeCompletionHandler?)
}

/**
 Transition takes responsibility for all the transition effects in current wireframe
 Each wireframe instance only has one transition instance(optional)
 
 After wireframe creating the destination view controller, before doing the navigation, 
 it will call transition(if has)'s set up method to set up tranition effect for it.
 */
public protocol SYWireframeTransition {
    
    func setupTransition(from soureViewController: UIViewController, to destinationViewController: UIViewController)
    
    func setupTransition(for navigationController: UINavigationController)
    
}

// MARK: Default Builders

/**
 A typical alert controller builder
 */
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

/**
 To make register much easier, user can register a closure to wireframe as an anonymous builder,
 this builder is simply a wraper for that closure
 */
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

/**
 Basic navigator which includs some very basic navigation ways,
 such as: present, dismiss, push, pop
 */
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

/**
 To make register much easier, user can register a closure to wireframe as an anonymous navigator,
 this navigator is simply a wraper for that closure
 */
struct SYClosureWrapNavigator: SYWireframeNavigator {

    let closure: (UIViewController, UIViewController, SYWireframeCompletionHandler?) -> Void
    
    public func navigate(from soureViewController: UIViewController, to destinationViewController: UIViewController, completion: SYWireframeCompletionHandler?) {
        closure(soureViewController, destinationViewController, completion)
    }

}
