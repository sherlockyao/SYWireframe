//
//  SYWireframeTransitionComponent.swift
//  SYWireframe
//
//  Created by SherlockYao on 10/24/16.
//  Copyright © 2016 SherlockYao. All rights reserved.
//

import UIKit

public protocol SYWireframeTransitionComponent {
    
    func setupTransition(fromViewController: UIViewController, toViewController: UIViewController)
    
    func setupTransition(navigationController: UINavigationController)
    
}
