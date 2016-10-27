//
//  SYWireframe.swift
//  SYWireframe
//
//  Created by SherlockYao on 10/24/16.
//  Copyright © 2016 SherlockYao. All rights reserved.
//

import UIKit

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
    
    /// view controller builders map: builderName -> builder
    private var builders: Dictionary<String, SYWireframeBuilder>
    
    /// view controller navigators map: navigatorName -> navigator
    private var navigators: Dictionary<String, SYWireframeNavigator>
    
    public var transition: SYWireframeTransition?
    
    
    /// Initializes an instance of wireframe, it will load the .plist file in current bundle,
    /// so make sure the file is in same bundle of your custom wireframe subclass
    ///
    /// - parameter plistName: the configuration .plist file name
    ///
    /// - returns: an instance of wireframe
    public convenience init(plistName: String) {
        let path = Bundle(for: type(of: self)).path(forResource: plistName, ofType: "plist")
        self.init(plistPath: path!)
    }
    
    /// Initializes an instance of wireframe, it will load the .plist file from the given path
    ///
    /// - parameter plistPath: the configuration .plist file path
    ///
    /// - returns: an instance of wireframe
    public init(plistPath: String) {
        let plist = NSDictionary(contentsOfFile: plistPath)!
        decodes = plist["Decodes"] as! Dictionary<String, Dictionary<String, String>>
        destinations = plist["Destinations"] as! Dictionary<String, Dictionary<String, String>>
        var codes = [String: String]()
        for (code, properties) in decodes {
            if let className = properties["class"] {
                codes.updateValue(code, forKey: className)
            }
        }
        self.codes = codes
        builders = [String: SYWireframeBuilder]()
        navigators = [String: SYWireframeNavigator]()
    }

    // MARK: Registration
    
    
    /// Register a builder with given name, 
    /// the name should be the same with the one you put in .plist file
    ///
    /// - parameter builder: the builder instance
    /// - parameter name:    name of the builder
    public func register(builder: SYWireframeBuilder, name: String) {
        builders.updateValue(builder, forKey: name)
    }
    
    
    /// Register a closure as an anonymous builder with given name,
    /// the name should be the same with the one you put in .plist file
    ///
    /// - parameter builderName: name of the builder
    /// - parameter closure:     the build function closure
    public func register(builderName: String, closure: @escaping (Dictionary<String, Any>?) -> UIViewController) {
        let builder = SYClosureWrapBuilder(closure: closure)
        register(builder: builder, name: builderName)
    }
    
    
    /// Register a navigator with given name,
    /// the name should be the same with the one you put in .plist file
    ///
    /// - parameter navigator: the navigator instance
    /// - parameter name:      name of the navigator
    public func register(navigator: SYWireframeNavigator, name: String) {
        navigators.updateValue(navigator, forKey: name)
    }
    
    
    /// Register a closure as an anonymous navigator with given name,
    /// the name should be the same with the one you put in .plist file
    ///
    /// - parameter navigatorName: name of the navigator
    /// - parameter closure:       the navigate function closure
    public func register(navigatorName: String, closure: @escaping (UIViewController, UIViewController, SYWireframeCompletionHandler?) -> Void) {
        let navigator = SYClosureWrapNavigator(closure: closure)
        register(navigator: navigator, name: navigatorName)
    }
    
    /**
     Register some default builders which provoided by the framework
     
     Default Builder list:
     - UIAlertController
     */
    public func registerDefaultBuilders() {
        register(builder: SYAlertControllerBuilder(), name: "alert");
    }
    
    /**
     Register some default navigators which provoided by the framework
     
     Default Navigator list:
     - animated-present (animated == true)
     - instant-present (animated == false)
     - animated-dismiss
     - instant-dismiss
     - animated-push
     - animated-pop
     - animated-pop-root
     */
    public func registerDefaultNavigators() {
        
        register(navigator: SYBasicNavigator(type: .animatedPresent), name: "animated-present")
        register(navigator: SYBasicNavigator(type: .instantPresent), name: "instant-present")
        register(navigator: SYBasicNavigator(type: .animatedDismiss), name: "animated-dismiss")
        register(navigator: SYBasicNavigator(type: .instantDismiss), name: "instant-dismiss")
        register(navigator: SYBasicNavigator(type: .animatedPush), name: "animated-push")
        register(navigator: SYBasicNavigator(type: .animatedPop), name: "animated-pop")
        register(navigator: SYBasicNavigator(type: .animatedPopRoot), name: "animated-pop-root")
    }

    // MARK: Configuration
    
    /**
     Override this method to setup your own configuration logic
     DO call super() while you override the method if you want reuse the transition setup flow
     
     - parameter to:   the view controller to be configured, i.e. the destination controller
     - parameter from: the from view controller which present the configured controller
     - parameter params:         parameters
     */
    open func configure(from soureViewController: UIViewController, to destinationViewController: UIViewController, params: Dictionary<String, Any>?) {
        if let transition = transition {
            if let navigationController = destinationViewController as? UINavigationController {
                transition.setupTransition(for: navigationController)
            }
            transition.setupTransition(from: soureViewController, to: destinationViewController)
        }
    }
    
    // MARK: Routing Methods
    
    
    /// Perform navigation from the give view controller
    ///
    /// The method will find and initialize the destination view controller 
    /// by given port & gate(if has), then use the relevant navigator to perform the navigatoin
    ///
    /// - parameter port:                 the port to navigate
    /// - parameter gate:                 the gate of port to naviate
    /// - parameter params:               the params for this navigation
    /// - parameter sourceViewController: soure view controller of navigation
    /// - parameter completion:           completion handler after the navigation is done
    public func navigateTo(port: String, gate: String? = nil, params: Dictionary<String, Any>? = nil, from sourceViewController: UIViewController, completion: SYWireframeCompletionHandler? = nil) {
        let destinationKey = generateDestinationKey(port: port, gate: gate, viewController: sourceViewController)
        
        if let destination = destinations[destinationKey] {
            let destinationCode = destination["target"]
            let destinationViewController = buildViewController(code: destinationCode, params: params)
            
            configure(from: sourceViewController, to: destinationViewController, params: params)
            
            if let navigatorName = destination["navigator"] {
                let navigator = navigators[navigatorName]!
                navigator.navigate(from: sourceViewController, to: destinationViewController, completion: completion)
            }
        }
    }
    
    /// Create UIViewController instance with given code and params
    /// It will look into plist file to decode the code and initializes the view controller
    /// 
    /// 1. If the view controller is configured to be init with a builder,
    ///    the method will get the relevant builder to build the view controller
    /// 2. If the view contrller is configured to be located in a storyboard,
    ///    the method will load the view contrller from storyboard
    ///
    /// - parameter code:   the code the view controller
    /// - parameter params: extra info/data for init the view controller
    ///
    /// - returns: the initialized view controller
    public func buildViewController(code: String?, params: Dictionary<String, Any>?) -> UIViewController {
        guard let code = code else {
            return UIViewController()
        }
        guard let context = decodes[code] else {
            return UIViewController()
        }
        
        if let builderName = context["builder"] {
            let builder = builders[builderName]!
            return builder.buildViewController(params: params)
        } else {
            let storyboardName = context["storyboard"]!
            let identifier = context["id"]!
            return UIStoryboard(name: storyboardName, bundle: nil).instantiateViewController(withIdentifier: identifier)
        }
    }
    
    // MARK: Private Section
    
    private func generateDestinationKey(port: String, gate: String? = nil, viewController: UIViewController) -> String {
        let viewControllerName = String(describing: type(of: viewController))
        let code = codes[viewControllerName]!
        if let gate = gate {
            return code + "-" + port + "-" + gate
        } else {
            return code + "-" + port
        }
    }
    
}
