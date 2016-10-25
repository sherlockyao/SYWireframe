//
//  SYWireframe.swift
//  SYWireframe
//
//  Created by SherlockYao on 10/24/16.
//  Copyright © 2016 SherlockYao. All rights reserved.
//

import UIKit

public typealias SYWireframeCompletionHandler = () -> Void
public typealias SYWireframeViewControllerBuilder = (Dictionary<String, AnyObject>) -> UIViewController
public typealias SYWireframeViewControllerNavigator = (UIViewController, UIViewController, @escaping SYWireframeCompletionHandler) -> Void

/**
 Wireframe deal with all the view controller initialization, configuration, navigation, transition etc. works.
 
 The basic wireframe rules are configured in the .plist file.
 A classic navigation flow from view controller <X> to <Y> will be like this:
 
 - wireframe look up configuration map for X with Port and Gate(optional), result Y
 - wireframe initialize Y with relevant builder and params
 - wireframe use relevant navigator to do the presentation from X to Y
 
 
 The Port and Gate are simply string combinations to identiy a navigation for a given view controller,
 for example:
 if view controller X has three navigation point to three different view controllers
 you can define X-Next-A, X-Next-B, X-Next-C or X-List, X-Detail, X-Setting for them, the rules are up to you.
 But for a convenience and ease of use, it will be good to follow some certain rules when you define them.
 The X is the Code you give to the view controller for short, remember to assign the real class name for it in the .plist setting file (section Decodes), so that the wireframe can find the right code for current navigating view controller automatically.
 
 
 There are two ways for wirefirm initialize a view controller:
 1. by storyboard, you can set the storyboard file name and the view controller's id in the .plist file
 2. by code, you can assign a builder name in .plist file, also register that builder to wirefirm by code
 Further more, if you want to configure your new view controllers, please subclass wireframe and override  `configureViewController:fromViewController:withParams:`
 
 
 You can pick any presentation effect as you want for each navigation, assing the navigator name in the .plist file and register the navigator to wirefirm for specific method, the libaray already set up a default navigator set for quick start.
 You can also set a transition component for more customized transition animations.
 
 */
open class SYWireframe {
    
    private let codes: Dictionary<String, String>
    private let decodes: Dictionary<String, Dictionary<String, String>>
    private let destinations: Dictionary<String, Dictionary<String, String>>
    
    // view controller builders map: builderName -> builder
    private var builders: Dictionary<String, SYWireframeViewControllerBuilder>
    
    // view controller navigators map: navigatorName -> navigator
    private var navigators: Dictionary<String, SYWireframeViewControllerNavigator>
    
    public var transitionComponent: SYWireframeTransitionComponent?
    
    public init(plistFileName: String) {
        let path = Bundle(for: type(of: self)).path(forResource: plistFileName, ofType: "plist")
        let plist = NSDictionary(contentsOfFile: path!)!
        decodes = plist["Decodes"] as! Dictionary<String, Dictionary<String, String>>
        destinations = plist["Destinations"] as! Dictionary<String, Dictionary<String, String>>
        var codes = [String: String]()
        for (code, properties) in decodes {
            if let className = properties["class"] {
                codes.updateValue(code, forKey: className)
            }
        }
        self.codes = codes
        builders = [String: SYWireframeViewControllerBuilder]()
        navigators = [String: SYWireframeViewControllerNavigator]()
    }

    // MARK: Registration
    
    public func registerBuilder(name: String, builder: @escaping SYWireframeViewControllerBuilder) {
        builders.updateValue(builder, forKey: name)
    }
    
    public func register(navigator: @escaping SYWireframeViewControllerNavigator, forName navigatorName: String) {
        navigators.updateValue(navigator, forKey: navigatorName)
    }
    
    /**
     Default Builder list:
     - UIAlertController
     */
    public func registerDefaultBuilders() {
        
        registerBuilder(name: "alert") { (params) -> UIViewController in
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
     Default Navigator list:
     - animated-present (animated == true)
     - instant-present (animated == false)
     - animated-dismiss
     - instand-dismiss
     - animated-push
     - animated-pop
     - animated-pop-root
     */
    public func registerDefaultNavigators() {
        register(navigator: { (fromViewController, toViewController, completionHandler) -> Void in
            fromViewController.present(toViewController, animated: true, completion: completionHandler)
            }, forName: "animated-present")
        
        register(navigator: { (fromViewController, toViewController, completionHandler) -> Void in
            fromViewController.present(toViewController, animated: false, completion: completionHandler)
            }, forName: "instant-present")
        
        register(navigator: { (fromViewController, toViewController, completionHandler) -> Void in
            fromViewController.dismiss(animated: true, completion: completionHandler)
            }, forName: "animated-dismiss")
        
        register(navigator: { (fromViewController, toViewController, completionHandler) -> Void in
            fromViewController.dismiss(animated: false, completion: completionHandler)
            }, forName: "instant-dismiss")
        
        register(navigator: { (fromViewController, toViewController, completionHandler) -> Void in
            fromViewController.navigationController?.pushViewController(toViewController, animated: true)
            completionHandler()
            }, forName: "animated-push")
        
        register(navigator: { (fromViewController, toViewController, completionHandler) -> Void in
            _ = fromViewController.navigationController?.popViewController(animated: true)
            completionHandler()
            }, forName: "animated-pop")
        
        register(navigator: { (fromViewController, toViewController, completionHandler) -> Void in
            _ = fromViewController.navigationController?.popToRootViewController(animated: true)
            completionHandler()
            }, forName: "animated-pop-root")
    }
    
    // MARK: Configuration
    
    /**
     Override this method to setup your own configuration logic
     DO call super() while you override the method if you want reuse the transition setup flow
     
     - parameter toViewController:   the view controller to be configured, i.e. the destination controller
     - parameter fromViewController: the from view controller which present the configured controller
     - parameter withParams:         parameters
     */
    open func configureWith(toViewController: UIViewController, fromViewController: UIViewController, withParams: Dictionary<String, AnyObject>) {
        if let transition = transitionComponent {
            if let navigationController = toViewController as? UINavigationController {
                transition.setupTransition(navigationController: navigationController)
            }
            transition.setupTransition(fromViewController: fromViewController, toViewController: toViewController)
        }
    }
    
    // MARK: Routing Methods
    
    public func navigateTo(port: String, fromViewController: UIViewController) {
        navigateTo(port: port, params: [String : AnyObject](), fromViewController: fromViewController)
    }
    
    public func navigateTo(port: String, params: Dictionary<String, AnyObject>, fromViewController: UIViewController) {
        navigateTo(port: port, params: params, fromViewController: fromViewController) { 
            // do nothing
        }
    }
    
    public func navigateTo(port: String, params: Dictionary<String, AnyObject>, fromViewController: UIViewController, completionHandler: @escaping SYWireframeCompletionHandler) {
        navigateTo(port: port, gate: nil, params: params, fromViewController: fromViewController, completionHandler: completionHandler)
    }
    
    public func navigateTo(port: String, gate: String?, params: Dictionary<String, AnyObject>, fromViewController: UIViewController, completionHandler: @escaping SYWireframeCompletionHandler) {
        let destinationKey = self.destinationKeyFor(port: port, gate: gate, viewController: fromViewController)
        if let destination = destinations[destinationKey] {
            let toCode = destination["target"]
            let toViewController = buildViewControllerWith(code: toCode, params: params)
            configureWith(toViewController: toViewController, fromViewController: fromViewController, withParams: params)
            if let navigatorName = destination["navigator"] {
                let navigator = navigators[navigatorName]!
                navigator(fromViewController, toViewController, completionHandler)
            }
        }
    }
    
    public func buildViewControllerWith(code: String?, params: Dictionary<String, AnyObject>) -> UIViewController {
        guard let code = code else {
            return UIViewController()
        }
        guard let context = decodes[code] else {
            return UIViewController()
        }
        
        if let builderName = context["builder"] {
            let builder = builders[builderName]!
            return builder(params)
        } else {
            let storyboardName = context["storyboard"]!
            let identifier = context["id"]!
            return UIStoryboard(name: storyboardName, bundle: nil).instantiateViewController(withIdentifier: identifier)
        }
    }
    
    // MARK: Private Section
    
    private func destinationKeyFor(port: String, gate: String? = nil, viewController: UIViewController) -> String {
        let viewControllerName = String(describing: type(of: viewController))
        let code = codes[viewControllerName]!
        if let gate = gate {
            return code + "-" + port + "-" + gate
        } else {
            return code + "-" + port
        }
    }
    
}
