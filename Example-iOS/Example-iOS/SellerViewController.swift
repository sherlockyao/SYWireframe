//
//  SellerViewController.swift
//  Example-iOS
//
//  Created by SherlockYao on 10/27/16.
//  Copyright © 2016 SherlockYao. All rights reserved.
//

import UIKit

class SellerViewController: UIViewController {

    // MARK: - Actions
    
    @IBAction func backButtonTouchUpInside(_ sender: AnyObject) {
        Wireframe.sharedWireframe.navigateTo(port: .back, from: self)
    }

}
